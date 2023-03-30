defmodule PlejadyWeb.UserAuth do
  @moduledoc """
  Provides LiveView hooks and helper functions for user authentication.
  """
  use PlejadyWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller

  alias Plejady.Accounts
  alias Phoenix.LiveView

  alias Ueberauth.Auth

  alias Plejady.Accounts.{User, Token, SuggestedAdmin}
  alias Plejady.Repo

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_cms_backend_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  A LiveView hook ensuring multiple levels of authentication.

  The first argument is an atom and can be `:ensure_authenticated`, `:ensure_admin` or `:ensure_lead`.
  """
  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session do
      %{"user_token" => user_token} ->
        {:cont,
         Phoenix.Component.assign_new(socket, :current_user, fn ->
           Token.get_user_by_session_token(user_token)
         end)}

      _ ->
        {:halt,
         socket
         |> LiveView.put_flash(:error, "Před vstupem do aplikace se musíte přihlásit.")
         |> LiveView.redirect(to: ~p"/")}
    end
  end

  def on_mount(:ensure_admin, _params, _session, %{assigns: %{current_user: user}} = socket) do
    if user.role == :user do
      {:halt,
       socket
       |> LiveView.put_flash(:error, "Přístup odepřen!")
       |> LiveView.redirect(to: ~p"/")}
    else
      {:cont, socket}
    end
  end

  def on_mount(:ensure_lead, _params, _session, %{assigns: %{current_user: user}} = socket) do
    if user.role != :lead do
      {:halt,
       socket
       |> LiveView.put_flash(:error, "Přístup odepřen!")
       |> LiveView.redirect(to: ~p"/")}
    else
      {:cont, socket}
    end
  end

  @doc """
  Creates a new socket and logs the user in.
  """
  def log_in_user(conn, user, params) do
    token = Token.generate_user_session_token(user)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> maybe_write_remember_me_cookie(token, params)
  end

  @doc """
  Renews the socket (clears all session data)
  """
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  @doc """
  Fetches the user that is saved in the socket token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)

    user = user_token && Token.get_user_by_session_token(user_token)

    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Transforms the Ueberauth.Auth struct into a User struct and saves it to the database.

  > This is a database action.
  """
  def get_user_by_auth(%Auth{} = auth) do
    case Repo.get_by(User, gid: auth.uid) do
      nil ->
        if Accounts.first_user?() do
          %User{
            gid: auth.uid,
            email: auth.info.email,
            given_name: auth.info.first_name,
            last_name: auth.info.last_name,
            role: :lead
          }
          |> Repo.insert!()
        else
          case SuggestedAdmin.get_by_email(auth.info.email) do
            nil ->
              %User{
                gid: auth.uid,
                email: auth.info.email,
                given_name: auth.info.first_name,
                last_name: auth.info.last_name
              }
              |> Repo.insert!()

            suggested_admin ->
              {:ok, %{user: user}} =
                Ecto.Multi.new()
                |> Ecto.Multi.insert(:user, %User{
                  gid: auth.uid,
                  email: auth.info.email,
                  given_name: auth.info.first_name,
                  last_name: auth.info.last_name,
                  role: :admin
                })
                |> Ecto.Multi.delete(:delete, suggested_admin)
                |> Repo.transaction()

              user
          end
        end

      existing_user ->
        existing_user
    end
  end

  @doc """
  Logs the user out.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Token.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      PlejadyWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  If a user is detected in the `conn` struct, they are automatically redirected to the app.
  """
  def redirect_if_user_is_authenticated(conn) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/app")
      |> halt()
    else
      conn
    end
  end
end

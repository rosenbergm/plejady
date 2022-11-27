defmodule PlejadyWeb.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Plejady.Token

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_cms_backend_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def log_in_user(conn, user, params) do
    token = Token.generate_user_session_token(user)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> maybe_write_remember_me_cookie(token, params)
  end

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

  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Token.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      PlejadyWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  # Plugs

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Pro zobrazení této stránky se musíte přihlásit!")
      |> maybe_store_return_to()
      |> redirect(to: "/")
      |> halt()
    end
  end

  def require_admin(conn, _opts) do
    if conn.assigns[:current_user].is_admin do
      conn
    else
      conn
      |> put_flash(:error, "Nejste administrátor!")
      |> maybe_store_return_to()
      |> redirect(to: "/")
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: "/app"
end

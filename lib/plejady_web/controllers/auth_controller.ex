defmodule PlejadyWeb.AuthController do
  @moduledoc """
  Controller for handling authentication. Uses Ueberauth to simplify the code in the app itself.
  """

  use PlejadyWeb, :controller

  plug Ueberauth

  alias Ueberauth.Auth
  alias Ueberauth.Auth.Info

  alias PlejadyWeb.UserAuth

  @doc """
  Called when Ueberauth tries to authenticate the user. Either the authentication method is supported and the calling of this function is hijacked by the Ueberauth provider, or this function is called and an error is shown.
  """
  def request(conn, _params) do
    conn
    |> put_flash(:error, "Metoda přihlášení není podporována.")
    |> redirect(to: ~p"/")
  end

  @doc """
  Used in the app router to log out the user.
  """
  def delete(conn, _params) do
    UserAuth.log_out_user(conn)
  end

  @doc """
  Callback after an OAuth authentication. Handles both successful and unsuccessful logins.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Přihlášení se nezdařilo. Zkuste to znovu.")
    |> redirect(to: ~p"/")
  end

  def callback(
        %{
          assigns: %{
            ueberauth_auth: %Auth{info: %Info{urls: %{website: "student.alej.cz"}}} = auth
          }
        } = conn,
        _params
      ) do
    user = UserAuth.get_user_by_auth(auth)

    conn
    |> UserAuth.log_in_user(user, %{})
    |> put_flash(:info, "Přihlášení bylo úspěšné!")
    |> redirect(to: ~p"/app")
  end

  def callback(%{assigns: %{ueberauth_auth: _auth}} = conn, _params) do
    conn
    |> put_flash(:error, "Musíte se přihlásit školním e-mailem.")
    |> redirect(to: ~p"/")
  end
end

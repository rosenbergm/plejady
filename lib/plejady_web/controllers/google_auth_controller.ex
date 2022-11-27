defmodule PlejadyWeb.GoogleAuthController do
  use PlejadyWeb, :controller

  alias Plejady.{Repo, User}
  alias PlejadyWeb.UserAuth

  def index(conn, %{"code" => code}) do
    {:ok, google_token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(google_token.access_token)

    if Map.get(profile, :hd) == "student.alej.cz" do
      user =
        case Repo.get_by(User, gid: profile.sub) do
          nil ->
            %User{
              gid: profile.sub,
              email: profile.email,
              given_name: profile.given_name,
              last_name: profile.family_name
            }
            |> Repo.insert!()

          existing_user ->
            existing_user
        end

      conn
      |> UserAuth.log_in_user(user, %{})
      |> put_flash(:info, "Přihlášení bylo úspěšné!")
      |> redirect(to: "/app")
    else
      conn
      |> put_flash(:error, "Musíte se přihlásit školním e-mailem.")
      |> redirect(to: "/app")
    end
  end

  def log_out(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end

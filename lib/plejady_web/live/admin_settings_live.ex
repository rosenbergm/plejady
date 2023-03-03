defmodule PlejadyWeb.AdminSettingsLive do
  use PlejadyWeb, :live_view

  alias Plejady.{Repo, Timeblock, Room, Presentation, User}
  import Ecto.Query

  def render(assigns) do
    render(PlejadyWeb.AdminSettingsView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    admins = from(u in User, where: u.is_admin, select: u) |> Repo.all()

    {:ok, assign(socket, %{admins: admins, changeset: User.Promotion.changeset()})}
  end

  def handle_event(
        "validate_promotion",
        %{"promotion" => params},
        socket
      ) do
    changeset =
      User.Promotion.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save_promotion",
        %{"promotion" => params},
        socket
      ) do
    with user when not is_nil(user) <- Repo.get_by(User, email: params["email"]),
         {:ok, _user} <- User.make_user_admin(user) do
      {
        :noreply,
        socket
        |> put_flash(:info, "Administrátor přidán!")
        |> push_redirect(to: "/admin/settings")
      }
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Uživatel s daným e-mailem neexistuje!")
         |> push_redirect(to: "/admin/settings")}
    end
  end
end

defmodule PlejadyWeb.AdminSettingsLive do
  use PlejadyWeb, :live_view

  alias Plejady.{Repo, Timeblock, Room, Presentation, User, SuggestedAdmin}
  import Ecto.Query

  def render(assigns) do
    render(PlejadyWeb.AdminSettingsView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    admins = from(u in User, where: u.is_admin, select: u) |> Repo.all()

    {:ok,
     assign(socket, %{admins: admins, changeset: SuggestedAdmin.changeset(%SuggestedAdmin{})})}
  end

  def handle_event(
        "validate_suggested_admin",
        %{"suggested_admin" => params},
        socket
      ) do
    changeset =
      %SuggestedAdmin{}
      |> SuggestedAdmin.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save_suggested_admin",
        %{"suggested_admin" => params},
        socket
      ) do
    case SuggestedAdmin.create(params) do
      {:ok, _admin} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Administrátor přidán!")
          |> push_patch(to: "/admin/settings", replace: true)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

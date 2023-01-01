defmodule PlejadyWeb.AppLive do
  use PlejadyWeb, :live_view
  # on_mount PlejadyWeb.UserLiveAuth

  alias Plejady.{Registry, Presentation, Repo, Room, Timeblock}

  import Ecto.Query

  def render(assigns) do
    render(PlejadyWeb.PageView, "app.html", assigns)
  end

  def mount(_params, _session, socket) do
    PlejadyWeb.Endpoint.subscribe("presentations")

    test_id = Ecto.UUID.generate()

    {:ok, registry} = Registry.get()

    {:ok,
     socket
     |> assign(
       occupancy: Registry.fetch_occupancy(),
       signed_up_for: Registry.fetch_signed_up_for(registry, test_id),
       timeblocks: registry.timeblocks,
       rooms: registry.rooms,
       presentations: registry.presentations,
       current_user: %{
         email: "hocuspocus",
         id: test_id,
         is_admin: false
       }
     )}
  end

  def handle_event(
        "toggle_presentation",
        %{
          "presentation" => presentation_id
        } = _values,
        %{
          assigns: %{current_user: current_user, signed_up_for: signed_up_for}
        } = socket
      ) do
    cache_update = Registry.update(signed_up_for, presentation_id, current_user.id)

    socket =
      case cache_update do
        {:error, :full} ->
          socket
          |> put_flash(
            :error,
            "Byla dosažena plná kapacita přednášky, na kterou se chcete přihlásit!"
          )

        {:error, _} ->
          socket

        {:ok, signed_up_for} ->
          PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "update_registry", nil)

          socket
          |> assign(occupancy: Registry.fetch_occupancy(), signed_up_for: signed_up_for)
      end

    {:noreply, socket}
  end

  def handle_event("toggle_presentation", _values, socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: "update_registry"}, socket) do
    {:noreply, assign(socket, occupancy: Registry.fetch_occupancy())}
  end
end

defmodule PlejadyWeb.AppLive do
  @moduledoc false

  use PlejadyWeb, :live_view

  alias Plejady.Registry

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlejadyWeb.Endpoint.subscribe("presentations")

    %{current_user: current_user} = socket.assigns

    {:ok, registry} = Registry.get()
    config = Plejady.Config.get_config()

    {:ok,
     socket
     |> assign(
       occupancy: Registry.fetch_occupancy(),
       signed_up_for: Registry.fetch_signed_up_for(registry, current_user.id),
       timeblocks: registry.timeblocks,
       rooms: registry.rooms,
       presentations: registry.presentations,
       config: config
     )}
  end

  def handle_event(
        "toggle-presentation",
        %{"presentation_id" => presentation_id},
        %{assigns: %{current_user: current_user, signed_up_for: signed_up_for}} = socket
      ) do
    cache_update = Registry.update(signed_up_for, presentation_id, current_user.id)

    {:noreply,
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
     end}
  end

  def handle_event("toggle-presentation", _values, socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: "update_registry"}, socket) do
    {:noreply, assign(socket, occupancy: Registry.fetch_occupancy())}
  end

  def handle_info(%{event: "refresh"}, socket) do
    config =
      Plejady.Config.get_config()
      |> IO.inspect()

    {:noreply,
     socket
     |> push_redirect(to: ~p"/app")
     |> put_flash(
       :info,
       if config.has_ended do
         "Přihlašování bylo ukončeno!"
       else
         "Přihlašování bylo spuštěno!"
       end
     )}
  end

  def format_datetime(nil), do: nil

  def format_datetime(datetime) do
    formatted(datetime, "d. MMMM yyyy") <> " v " <> formatted(datetime, "HH:mm")
  end

  defp formatted(datetime, format_string) do
    Plejady.Cldr.DateTime.to_string!(
      datetime |> DateTime.shift_zone!("Europe/Prague", Tz.TimeZoneDatabase),
      format: format_string
    )
  end
end

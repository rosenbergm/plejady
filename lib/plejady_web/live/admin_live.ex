defmodule PlejadyWeb.AdminLive do
  use PlejadyWeb, :live_view

  alias Plejady.{Repo, Timeblock, Room, Presentation}
  import Ecto.Query

  def render(assigns) do
    render(PlejadyWeb.AdminView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    timeblocks = Repo.all(Timeblock)
    rooms = Repo.all(from r in Room, order_by: r.name, select: r)
    presentations = Repo.all(Presentation)

    {:ok,
     socket
     |> assign(
       timeblocks: timeblocks,
       rooms: rooms,
       presentations: presentations,
       # This can be `:none` or {<name>, <params>}
       open_modal: {:none}
       #  show_room_modal: false,
       #  show_timeblock_modal: false,
       #  show_presentation_modal: false
     )}
  end

  def handle_event("delete-room", %{"room-id" => room_id} = _params, socket) do
    case Repo.delete(Repo.get(Room, room_id)) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> push_navigate(to: "/admin", replace: true)
         |> put_flash(:info, "Místnost byla odstraněna!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Nepodařilo se odstranit místnost!")}
    end
  end

  def handle_event("delete-timeblock", %{"timeblock-id" => timeblock_id} = _params, socket) do
    case Repo.delete(Repo.get(Timeblock, timeblock_id)) do
      {:ok, _presentation} ->
        {:noreply,
         socket
         |> push_navigate(to: "/admin", replace: true)
         |> put_flash(:info, "Časový blok byl odstraněn!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Nepodařilo se odstranit časový blok!")}
    end
  end

  def handle_event(
        "delete-presentation",
        %{"presentation-id" => presentation_id} = _params,
        socket
      ) do
    case Repo.delete(Repo.get(Presentation, presentation_id)) do
      {:ok, _presentation} ->
        {:noreply,
         socket
         |> push_navigate(to: "/admin", replace: true)
         |> put_flash(:info, "Přednáška byla odstraněna!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Nepodařilo se odstranit přednášku!")}
    end
  end

  def handle_event("open-room-modal", _params, socket) do
    {:noreply, assign(socket, open_modal: {"room"})}
  end

  def handle_event("open-timeblock-modal", _params, socket) do
    {:noreply, assign(socket, open_modal: {"timeblock"})}
  end

  def handle_event(
        "open-presentation-modal",
        %{"room-id" => room_id, "room-capacity" => room_capacity, "timeblock-id" => timeblock_id} =
          _params,
        socket
      ) do
    {:noreply,
     assign(socket,
       open_modal:
         {"presentation",
          %{room_id: room_id, room_capacity: room_capacity, timeblock_id: timeblock_id}}
     )}
  end

  def handle_event(
        "open-presentation-edit-modal",
        %{"presentation-id" => presentation_id} = _params,
        socket
      ) do
    {:noreply,
     assign(socket,
       open_modal: {"presentation-edit", %{presentation_id: presentation_id}}
     )}
  end

  def handle_info({_, :close}, socket) do
    {:noreply, assign(socket, open_modal: {:none})}
  end
end

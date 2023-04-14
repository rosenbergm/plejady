defmodule PlejadyWeb.AdminLive.Index do
  @moduledoc false

  alias Plejady.Presentation
  alias Plejady.Room
  alias Plejady.Timeblock
  use PlejadyWeb, :live_view

  on_mount {PlejadyWeb.UserAuth, :ensure_lead}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       timeblocks: Timeblock.all(),
       rooms: Room.all(),
       presentations: Presentation.all()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_presentation, %{"id" => id}) do
    socket
    |> assign(:page_title, "Úprava přednášky")
    |> assign(:presentation, Presentation.get!(id))
  end

  defp apply_action(
         %{assigns: %{presentation: _presentation}} = socket,
         :new_presentation,
         _params
       ) do
    socket
  end

  defp apply_action(socket, :new_presentation, _params) do
    socket
    |> push_patch(to: ~p"/admin")
  end

  defp apply_action(socket, :edit_room, %{"id" => id}) do
    socket
    |> assign(:page_title, "Úprava místnosti")
    |> assign(:room, Room.get!(id))
  end

  defp apply_action(socket, :new_room, _params) do
    socket
    |> assign(:page_title, "Nová místnost")
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, :edit_timeblock, %{"id" => id}) do
    socket
    |> assign(:page_title, "Úprava časového bloku")
    |> assign(:timeblock, Timeblock.get!(id))
  end

  defp apply_action(socket, :new_timeblock, _params) do
    socket
    |> assign(:page_title, "Nový časový blok")
    |> assign(:timeblock, %Timeblock{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Panel administrace")
    |> assign(presentation: nil, timeblock: nil, room: nil)
  end

  @impl true
  def handle_event("delete-room", %{"id" => id}, socket) do
    {:ok, _} = Room.delete(id)

    {:noreply,
     socket
     |> put_flash(:info, "Místnost byla odstraňena!")
     |> push_navigate(to: ~p"/admin")}
  end

  @impl true
  def handle_event("delete-timeblock", %{"id" => id}, socket) do
    {:ok, _} = Timeblock.delete(id)

    {:noreply,
     socket
     |> put_flash(:info, "Časový blok byl odstraňen!")
     |> push_navigate(to: ~p"/admin")}
  end

  @impl true
  def handle_event("delete-presentation", %{"id" => id}, socket) do
    {:ok, _} = Presentation.delete(id)

    {:noreply,
     socket
     |> put_flash(:info, "Přednáška byla odstraněna!")
     |> push_navigate(to: ~p"/admin")}
  end

  @impl true
  def handle_event(
        "new-presentation",
        %{"room_id" => room_id, "timeblock_id" => timeblock_id},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:page_title, "Nová přednáška")
     |> assign(:presentation, %Presentation{room_id: room_id, timeblock_id: timeblock_id})
     |> push_patch(to: ~p"/admin/presentation")}
  end

  @impl true
  def handle_info({PlejadyWeb.AdminLive.CreatePresentation, {:saved, _}}, socket) do
    {:noreply, assign(socket, presentations: Presentation.all())}
  end

  @impl true
  def handle_info({PlejadyWeb.AdminLive.CreateRoom, {:saved, _}}, socket) do
    {:noreply, assign(socket, rooms: Room.all())}
  end

  @impl true
  def handle_info({PlejadyWeb.AdminLive.CreateTimeblock, {:saved, _}}, socket) do
    {:noreply, assign(socket, timeblocks: Timeblock.all())}
  end
end

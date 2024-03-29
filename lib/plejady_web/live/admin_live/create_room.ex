defmodule PlejadyWeb.AdminLive.CreateRoom do
  @moduledoc false

  use PlejadyWeb, :live_component

  alias Plejady.Room

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="room-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:name]}
          type="text"
          label="Číslo (jméno) místnosti"
          placeholder="105"
        />
        <.input field={@form[:capacity]} type="number" label="Kapacita" placeholder="60" />

        <:actions>
          <.button phx-disable-with="Ukládám...">Uložit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{room: room} = assigns, socket) do
    changeset = Room.changeset(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"room" => params},
        socket
      ) do
    changeset =
      socket.assigns.room
      |> Room.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"room" => params},
        socket
      ) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :edit_room, params) do
    case Room.update(socket.assigns.room, params) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "Místnost úspěšně upravena!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save(socket, :new_room, params) do
    case Room.create(params) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "Místnost byla vytvořena!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

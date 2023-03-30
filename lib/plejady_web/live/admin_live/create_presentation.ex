defmodule PlejadyWeb.AdminLive.CreatePresentation do
  @moduledoc false

  use PlejadyWeb, :live_component

  alias Plejady.{Presentation, Room}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="presentation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:presenter]}
          type="text"
          label="Jméno přednášejícího"
          placeholder="Petr Fiala"
        />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Krátký popisek"
          placeholder="Volby jsou pro politika jedním z nejkrušnějších období života..."
        />
        <.input
          field={@form[:capacity]}
          type="number"
          label={"Vlastní kapacita přednášky (nyní #{@room.capacity})"}
          placeholder="20"
        />

        <:actions>
          <.button phx-disable-with="Ukládám...">Uložit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{presentation: presentation} = assigns, socket) do
    changeset = Presentation.changeset(presentation)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(room: Room.get!(presentation.room_id))
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"presentation" => params},
        # %{assigns: %{room_id: room_id, timeblock_id: timeblock_id}} = socket
        socket
      ) do
    changeset =
      socket.assigns.presentation
      |> Presentation.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"presentation" => params},
        socket
      ) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :edit_presentation, params) do
    case Presentation.update(socket.assigns.presentation, params) do
      {:ok, presentation} ->
        notify_parent({:saved, presentation})

        {:noreply,
         socket
         |> put_flash(:info, "Přednáška úspěšně upravena!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save(socket, :new_presentation, params) do
    case Presentation.create(socket.assigns.presentation, params) do
      {:ok, presentation} ->
        notify_parent({:saved, presentation})

        {:noreply,
         socket
         |> put_flash(:info, "Přednáška byla vytvořena!")
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

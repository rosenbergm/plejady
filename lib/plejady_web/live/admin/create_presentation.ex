defmodule PlejadyWeb.Admin.CreatePresentation do
  use PlejadyWeb, :live_component

  alias Plejady.{Presentation}

  def mount(socket) do
    {:ok,
     assign(socket, %{
       changeset: Presentation.changeset(%Presentation{})
     })}
  end

  def render(assigns) do
    ~H"""
    <div id={@myself}>
      <div class="header">
        <h4>Vytvořit novou přednášku</h4>
        <button class="icon" phx-click="close" phx-target={@myself}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <%= label(f, :presenter, "Jméno přednášejícího") %>
        <%= text_input(f, :presenter) %>
        <%= error_tag(f, :presenter) %>

        <%= label(f, :description, "Krátký popisek") %>
        <%= textarea(f, :description) %>
        <%= error_tag(f, :description) %>

        <%= label(
          f,
          :capacity,
          "Kapacita"
        ) %>
        <%= text_input(f, :capacity, placeholder: "#{@room_capacity} (kapacita místnosti)") %>
        <%= error_tag(f, :capacity) %>

        <%= submit("Uložit", phx_disable_with: "Ukládám...") %>
      </.form>
    </div>
    """
  end

  def handle_event("close", _params, socket) do
    send(self(), {__MODULE__, :close})

    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{"presentation" => params},
        %{assigns: %{room_id: room_id, timeblock_id: timeblock_id}} = socket
      ) do
    changeset =
      %Presentation{
        room_id: room_id,
        timeblock_id: timeblock_id
      }
      |> Presentation.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save",
        %{"presentation" => presentation_params},
        %{assigns: %{room_id: room_id, timeblock_id: timeblock_id}} = socket
      ) do
    case Presentation.create_presentation(
           %Presentation{},
           Map.merge(presentation_params, %{"room_id" => room_id, "timeblock_id" => timeblock_id})
         ) do
      {:ok, _presentation} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Přednáška byla vytvořena!")
          |> push_navigate(to: "/admin", replace: true)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

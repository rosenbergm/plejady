defmodule PlejadyWeb.Admin.EditPresentation do
  use PlejadyWeb, :live_component

  alias Plejady.{Presentation, Repo}

  def mount(socket) do
    {:ok,
     assign(socket, %{
       changeset: Presentation.changeset(%Presentation{})
     })}
  end

  def update(%{presentation_id: presentation_id} = _assigns, socket) do
    presentation =
      Presentation
      |> Repo.get(presentation_id)
      |> Repo.preload([:room])

    {:ok,
     assign(socket, changeset: Presentation.changeset(presentation), room: presentation.room)}
  end

  def render(assigns) do
    ~H"""
    <div id={@myself}>
      <div class="header">
        <h4>Upravit přednášku</h4>
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
        <%= label(f, :presenter) %>
        <%= text_input(f, :presenter) %>
        <%= error_tag(f, :presenter) %>

        <%= label(f, :description) %>
        <%= text_input(f, :description) %>
        <%= error_tag(f, :description) %>

        <%= label(
          f,
          :capacity,
          "Kapacita"
        ) %>
        <%= text_input(f, :capacity, placeholder: "#{@room.capacity} (kapacita místnosti)") %>
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
        %{assigns: %{changeset: changeset}} = socket
      ) do
    changeset =
      changeset
      |> Presentation.changeset(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save",
        _params,
        %{assigns: %{changeset: changeset}} = socket
      ) do
    case Presentation.update_presentation(changeset) do
      {:ok, _presentation} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Přednáška byla upravena!")
          |> push_navigate(to: "/admin", replace: true)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

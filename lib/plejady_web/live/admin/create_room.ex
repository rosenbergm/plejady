defmodule PlejadyWeb.Admin.CreateRoom do
  use PlejadyWeb, :live_component

  alias Plejady.{Room}

  def mount(socket) do
    {:ok, assign(socket, %{changeset: Room.changeset(%Room{})})}
  end

  def render(assigns) do
    ~H"""
    <div id={@myself}>
      <div class="header">
        <h4>Vytvořit novou místnost</h4>
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
        <%= label(f, :name, "Číslo místnosti (jméno)") %>
        <%= text_input(f, :name) %>
        <%= error_tag(f, :name) %>

        <%= label(f, :capacity, "Kapacita") %>
        <%= text_input(f, :capacity, type: "number") %>
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

  def handle_event("validate", %{"room" => params}, socket) do
    changeset =
      %Room{}
      |> Room.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    case Room.create_room(%Room{}, room_params) do
      {:ok, _room} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Místnost byla vytvořena!")
          |> push_navigate(to: "/admin", replace: true)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

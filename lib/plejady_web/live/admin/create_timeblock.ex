defmodule PlejadyWeb.Admin.CreateTimeblock do
  use PlejadyWeb, :live_component

  alias Plejady.{Timeblock}

  def mount(socket) do
    {:ok, assign(socket, %{changeset: Timeblock.changeset(%Timeblock{})})}
  end

  def render(assigns) do
    ~H"""
    <div id={@myself}>
      <div class="header">
        <h4>Vytvořit nový časový blok</h4>
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
        <%= label(f, :block_start, "Začátek") %>
        <%= text_input(f, :block_start, type: :time, step: 60) %>
        <%= error_tag(f, :block_start) %>

        <%= label(f, :block_end, "Konec") %>
        <%= text_input(f, :block_end, type: :time, step: 60) %>
        <%= error_tag(f, :block_end) %>

        <%= submit("Uložit", phx_disable_with: "Ukládám...") %>
      </.form>
    </div>
    """
  end

  def handle_event("close", _params, socket) do
    send(self(), {__MODULE__, :close})

    {:noreply, socket}
  end

  def handle_event("validate", %{"timeblock" => params}, socket) do
    changeset =
      %Timeblock{}
      |> Timeblock.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"timeblock" => timeblock_params}, socket) do
    case Timeblock.create_timeblock(timeblock_params) do
      {:ok, _timeblock} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Časový blok byl vytvořen!")
          |> push_navigate(to: "/admin", replace: true)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

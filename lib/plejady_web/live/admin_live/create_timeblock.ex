defmodule PlejadyWeb.AdminLive.CreateTimeblock do
  @moduledoc false

  use PlejadyWeb, :live_component

  alias Plejady.Timeblock

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="timeblock-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:block_start]} type="time" step="60" label="Začátek" />
        <.input field={@form[:block_end]} type="time" step="60" label="Konec" />

        <:actions>
          <.button phx-disable-with="Ukládám...">Uložit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{timeblock: timeblock} = assigns, socket) do
    changeset = Timeblock.changeset(timeblock)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"timeblock" => params},
        socket
      ) do
    changeset =
      socket.assigns.timeblock
      |> Timeblock.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"timeblock" => params},
        socket
      ) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :edit_timeblock, params) do
    case Timeblock.update(socket.assigns.timeblock, params) do
      {:ok, timeblock} ->
        notify_parent({:saved, timeblock})

        {:noreply,
         socket
         |> put_flash(:info, "Časový block úspěšně upraven!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save(socket, :new_timeblock, params) do
    case Timeblock.create(params) do
      {:ok, timeblock} ->
        notify_parent({:saved, timeblock})

        {:noreply,
         socket
         |> put_flash(:info, "Časový blok byl vytvořen!")
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

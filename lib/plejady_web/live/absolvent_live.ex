defmodule PlejadyWeb.AbsolventLive do
  use PlejadyWeb, :live_view

  alias Plejady.{Absolvent, Repo}

  def render(assigns) do
    render(PlejadyWeb.PageView, "absolvent.html", assigns)
  end

  def mount(_params, _session, socket) do
    free_places =
      Repo.aggregate(Absolvent, :count)
      |> Kernel.-(30)
      |> abs()
      |> Integer.to_string()

    changeset = Absolvent.new(%Absolvent{})

    {:ok,
     socket
     |> assign(free_places: free_places, changeset: changeset)}
  end

  def handle_event("validate", %{"absolvent" => params}, socket) do
    changeset =
      %Absolvent{}
      |> Absolvent.new(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"absolvent" => user_params}, socket) do
    case %Absolvent{} |> Absolvent.new(user_params) |> Repo.insert() do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Absolvent úspěšně zapsán!")
         |> redirect(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

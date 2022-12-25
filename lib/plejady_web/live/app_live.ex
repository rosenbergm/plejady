defmodule PlejadyWeb.AppLive do
  use PlejadyWeb, :live_view
  on_mount PlejadyWeb.UserLiveAuth

  alias Plejady.{Presentation, Registration, Repo, Room, Timeblock}
  import Ecto.Query

  # TODO: Try the same PubSub setting BUT don't send data over the connection. Instead, fetch the data from Cachex (no need for the Plejady.Updater GenServer)

  def render(assigns) do
    render(PlejadyWeb.PageView, "app.html", assigns)
  end

  def mount(_params, _session, socket) do
    PlejadyWeb.Endpoint.subscribe("presentations")

    rooms = Repo.all(from r in Room, order_by: r.name, select: r)
    timeblocks = Repo.all(from t in Timeblock, order_by: t.block_start, select: t)

    {:ok,
     socket
     |> assign(
       registry: Cachex.get!(:cache, :registry),
       timeblocks: timeblocks,
       rooms: rooms,
       presentations: Repo.all(Presentation)
     )}
  end

  def handle_info(%{event: "ping", payload: _}, socket) do
    registry = Cachex.get!(:cache, :registry)

    {:noreply, assign(socket, %{registry: registry})}
  end

  defp user_already_signed_somewhere(registry, presentations, timeblock, user) do
    available =
      presentations
      |> Enum.filter(&(&1.timeblock_id == timeblock))
      |> Enum.map(& &1.id)

    registry
    |> Map.to_list()
    |> Enum.filter(fn {presentation_id, user_list} ->
      presentation_id in available and user in user_list
    end)
    |> case do
      [{presentation_id, _user_list}] ->
        presentation_id

      _ ->
        nil
    end
  end

  defp int(num) when is_integer(num) do
    num
  end

  defp int(num) when is_binary(num) do
    String.to_integer(num)
  end

  defp sign_to_presentation(
         {:commit, registry},
         capacity,
         presentation_id,
         user_id
       ) do
    if Map.get(registry, presentation_id, []) |> length() < int(capacity) do
      Task.start(fn ->
        Registration.new(presentation_id, user_id)
      end)

      {:commit,
       registry
       |> Map.update(presentation_id, [user_id], &[user_id | &1])}
    else
      {:ignore, {:full, registry}}
    end
  end

  defp sign_to_presentation(
         {:ignore, {_reason, _registry}} = payload,
         _capacity,
         _presentation_id,
         _user_id
       ) do
    payload
  end

  defp unsign_from_presentation({:commit, registry}, presentation_id, user_id) do
    Task.start(fn ->
      Registration.delete(presentation_id, user_id)
    end)

    {:commit,
     registry
     |> Map.update(presentation_id, [user_id], fn user_list ->
       Enum.reject(user_list, &(&1 == user_id))
     end)}
  end

  defp unsign_from_presentation(
         {:ignore, {_reason, _registry}} = payload,
         _presentation_id,
         _user_id
       ) do
    payload
  end

  def handle_event(
        "toggle_presentation",
        %{"presentation" => presentation, "timeblock" => timeblock, "capacity" => room_capacity} =
          _values,
        %{assigns: %{current_user: current_user, presentations: presentations}} = socket
      ) do
    cache_update =
      Cachex.get_and_update(:cache, :registry, fn prev ->
        cache = {:commit, prev}

        if signed_presentation =
             user_already_signed_somewhere(prev, presentations, timeblock, current_user.id) do
          if presentation == signed_presentation do
            {:ignore, nil}
          else
            cache
            |> unsign_from_presentation(signed_presentation, current_user.id)
            |> sign_to_presentation(
              room_capacity,
              presentation,
              current_user.id
            )
          end
        else
          cache
          |> sign_to_presentation(
            room_capacity,
            presentation,
            current_user.id
          )
        end
      end)

    socket =
      case cache_update do
        {:ignore, {:full, _registry}} ->
          socket
          |> put_flash(
            :error,
            "Byla dosažena plná kapacita přednášky, na kterou se chcete přihlásit!"
          )

        {:ignore, nil} ->
          socket

        {:commit, registry} ->
          socket
          |> assign(:registry, registry)
      end

    {:noreply, socket}
  end

  def handle_event("toggle_presentation", _values, socket) do
    {:noreply, socket}
  end
end

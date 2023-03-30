defmodule Plejady.CacheInitiator do
  @moduledoc """
  This module is responsible for initializing the cache with the data from the database.

  Implements `GenServer` behaviour.
  """

  use GenServer
  alias Plejady.{Registration, Presentation, Room, Timeblock, Repo, Registry}

  import Ecto.Query

  @impl true
  def init(_) do
    Repo.all(Presentation)
    |> Enum.reduce(%{}, fn %{id: presentation_id}, acc ->
      Map.put(acc, presentation_id, [])
    end)
    |> then(fn empty_registry ->
      Repo.all(Registration)
      |> Enum.reduce(empty_registry, fn %{user_id: user_id, presentation_id: presentation_id},
                                        acc ->
        Map.update(acc, presentation_id, [user_id], &[user_id | &1])
      end)
    end)
    |> Enum.each(fn {id, users} ->
      Cachex.put(Registry.cache_name(), id, users)
    end)

    rooms = Repo.all(from r in Room, order_by: r.name, select: r)
    timeblocks = Repo.all(from t in Timeblock, order_by: t.block_start, select: t)
    presentations = Repo.all(Presentation)

    Cachex.put(
      Registry.cache_name(),
      :registry,
      Registry.new(presentations, rooms, timeblocks)
    )

    :ignore
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end
end

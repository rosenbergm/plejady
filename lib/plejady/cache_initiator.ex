defmodule Plejady.CacheInitiator do
  use GenServer
  alias Plejady.{Registration, Repo}

  @impl true
  def init(_) do
    registry =
      Repo.all(Registration)
      |> Enum.reduce(%{}, fn %Registration{user_id: user_id, presentation_id: presentation_id},
                             acc ->
        Map.update(acc, presentation_id, [user_id], &[user_id | &1])
      end)

    Cachex.put(:cache, :registry, registry)

    :ignore
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end
end

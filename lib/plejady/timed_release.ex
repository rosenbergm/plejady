defmodule Plejady.TimedRelease do
  @moduledoc """
  GenServer for handling timed release of the application.
  """
  use GenServer

  alias Plejady.{CacheInitiator, Config}
  alias Plejady.Config.Schema

  @impl true
  def init(time) do
    send(self(), :tick)

    {:ok, time}
  end

  @impl true
  def handle_cast({:update, new_time}, _old_time) do
    {:noreply, new_time}
  end

  @impl true
  def handle_info(:tick, time) do
    if DateTime.compare(DateTime.utc_now(), time) == :gt do
      CacheInitiator.initiate()

      %Schema{
        is_open: true,
        timed_release: nil
      }
      |> Config.set_config()

      PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "refresh", nil)

      send(self(), :kill)
    end

    Process.send_after(self(), :tick, 1000)

    {:noreply, time}
  end

  @impl true
  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end
end

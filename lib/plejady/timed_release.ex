defmodule Plejady.TimedRelease do
  @moduledoc """
  GenServer for handling timed release of the application.
  """
  use GenServer

  alias Plejady.{CacheInitiator, Config}

  @impl true
  def init({start_time, end_time}) do
    send(self(), :tick)

    {:ok, {start_time, end_time}}
  end

  @impl true
  def handle_cast({:update, {_start_time, _end_time} = new_time}, _old_time) do
    {:noreply, new_time}
  end

  @impl true
  def handle_info(:tick, {start_time, end_time} = timing) do
    config = Config.get_config()

    if not config.is_open && DateTime.compare(DateTime.utc_now(), start_time) == :gt do
      CacheInitiator.initiate()

      %{
        is_open: true,
        has_ended: false,
        timed_release: nil
      }
      |> Config.update_config()

      PlejadyWeb.Endpoint.broadcast_from(self(), "refresher", "refresh", nil)
    end

    if config.is_open && DateTime.compare(DateTime.utc_now(), end_time) == :gt do
      CacheInitiator.initiate()

      %{
        is_open: false,
        has_ended: true,
        timed_release: nil,
        timed_release_end: nil
      }
      |> Config.update_config()

      PlejadyWeb.Endpoint.broadcast_from(self(), "refresher", "refresh", nil)

      send(self(), :kill)
    end

    Process.send_after(self(), :tick, 5000)

    {:noreply, timing}
  end

  @impl true
  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end
end

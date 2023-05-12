defmodule Plejady.TimedRelease do
  @moduledoc """
  GenServer for handling timed release of the application.
  """
  use GenServer

  alias Plejady.{CacheInitiator, Config, Registry}

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

      send(self(), :test_registry)

      %{
        is_open: true,
        has_ended: false,
        timed_release: nil
      }
      |> Config.update_config()

      PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "refresh", nil)
    end

    if config.is_open && DateTime.compare(DateTime.utc_now(), end_time) == :gt do
      # ! Uncomment when not brute testing the system.
      # CacheInitiator.initiate()

      %{
        is_open: false,
        has_ended: true,
        timed_release: nil,
        timed_release_end: nil
      }
      |> Config.update_config()

      PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "refresh", nil)

      send(self(), :kill)
    end

    Process.send_after(self(), :tick, 5000)

    {:noreply, timing}
  end

  # ! Uncomment this handler to brute test the system.
  @impl true
  def handle_info(:test_registry, timing) do
    presentations = Registry.get() |> elem(1) |> then(& &1.presentations)

    Enum.each(0..9, fn _ ->
      Registry.update(
        [],
        Enum.random(presentations).id,
        "fake_#{:crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)}"
      )
    end)

    PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "update_registry", nil)

    Process.send_after(self(), :test_registry, 2000)

    {:noreply, timing}
  end

  @impl true
  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end
end

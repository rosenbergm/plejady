defmodule Plejady.BruteTester do
  @moduledoc false

  use GenServer

  alias Plejady.Registry

  @impl true
  def init(_) do
    send(self(), :tick)

    {:ok, nil}
  end

  @impl true
  def handle_info(:tick, _) do
    presentations = Registry.get() |> elem(1) |> then(& &1.presentations)

    Enum.each(0..9, fn _ ->
      Registry.update(
        [],
        Enum.random(presentations).id,
        "fake_#{:crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)}"
      )
    end)

    PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "update_registry", nil)

    Process.send_after(self(), :tick, 2000)

    {:noreply, nil}
  end

  @impl true
  def handle_cast(:kill, _) do
    {:stop, :normal, nil}
  end
end

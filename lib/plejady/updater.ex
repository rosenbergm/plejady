defmodule Plejady.Updater do
  use GenServer

  @impl true
  def init(_) do
    schedule()

    {:ok, nil}
  end

  defp schedule() do
    Process.send_after(
      self(),
      :process,
      500
    )
  end

  @impl true
  def handle_info(:process, _state) do
    schedule()

    PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "ping", nil)

    {:noreply, nil}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end
end

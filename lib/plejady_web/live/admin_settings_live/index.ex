defmodule PlejadyWeb.AdminSettingsLive.Index do
  @moduledoc false

  use PlejadyWeb, :live_view

  alias Plejady.Accounts

  on_mount {UserAuth, :ensure_lead}

  @impl true
  def mount(_params, _session, socket) do
    admins = Accounts.get_admins()

    {:ok, socket |> stream(:admins, admins)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Další nastavení")
  end
end

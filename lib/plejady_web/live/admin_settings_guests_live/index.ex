defmodule PlejadyWeb.AdminSettingsGuestsLive.Index do
  @moduledoc false

  use PlejadyWeb, :live_view

  alias Plejady.Accounts

  on_mount {UserAuth, :ensure_lead}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(guests: Accounts.guests())}
  end

  def render(assigns) do
    ~H"""
    <.app_header title="Seznam hostů" current_user={@current_user}>
      <:actions>
        <.link
          navigate={~p"/admin/settings"}
          class="text-sm font-medium tracking-tight underline hover:no-underline"
        >
          ← Zpět
        </.link>
      </:actions>
    </.app_header>

    <section class="print:space-y-0 space-y-10 w-screen overflow-y-auto">
      <article class="print:hidden px-4 lg:px-16 flex items-center gap-6 flex-wrap">
        <.button phx-click={JS.dispatch("print")}>
          <.icon name="hero-printer" class="mr-1" /> Tisknout
        </.button>
      </article>

      <article class="px-4 lg:px-16 space-y-6 pb-8">
        <h2 class="font-bold text-lg">
          Seznam hostů
        </h2>

        <.table id="guestlist" class="pagebreak" rows={@guests}>
          <:col :let={guest} label="E-mail"><%= guest.email %></:col>
        </.table>
      </article>
    </section>
    """
  end
end

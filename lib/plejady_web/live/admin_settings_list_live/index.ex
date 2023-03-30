defmodule PlejadyWeb.AdminSettingsListLive.Index do
  @moduledoc false

  use PlejadyWeb, :live_view

  alias Plejady.Presentation
  alias PlejadyWeb.UserAuth

  # TODO: Uncomment this!
  # on_mount {UserAuth, :ensure_lead}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(presentations: Presentation.all_preloaded())}
  end

  def render(assigns) do
    ~H"""
    <.app_header title="Seznam pro vedení školy" current_user={@current_user}>
      <:actions>
        <.link
          navigate={~p"/admin/settings"}
          class="text-sm font-medium tracking-tight underline hover:no-underline"
        >
          Další nastavení
        </.link>
      </:actions>
    </.app_header>

    <section class="print:space-y-0 space-y-10 w-screen overflow-y-auto">
      <article class="print:hidden px-4 lg:px-16 flex items-center gap-6 flex-wrap">
        <p class="text-base font-normal tracking-tighter">
          Po ukončení přihlašování si tuto stránku vytiskněte a rozneste do tříd, kde se jednotlivé přednášky konají.
        </p>

        <.button phx-click={JS.dispatch("print")}>
          <.icon name="hero-printer" class="mr-1" /> Tisknout
        </.button>
      </article>

      <article :for={p <- @presentations} class="px-4 lg:px-16 space-y-6 pb-8">
        <h2 class="font-bold text-lg">
          <%= p.room.name %> (<%= Plejady.Timeblock.format_time(p.timeblock.block_start) %>–<%= Plejady.Timeblock.format_time(
            p.timeblock.block_end
          ) %>, <%= length(p.registrations) %>/<%= Map.get(p, :capacity) || Map.get(p.room, :capacity) %>): <%= p.presenter %>
        </h2>
        <.table id={"sheet_#{p.id}"} class="pagebreak" rows={p.registrations}>
          <:col :let={reg} label="Jméno"><%= reg.user.given_name %> <%= reg.user.last_name %></:col>
          <:col :let={reg} label="E-mail"><%= reg.user.email %></:col>
          <:col :let={_reg} class="w-[160px]" label="Podpis"></:col>
        </.table>
      </article>
    </section>
    """
  end
end

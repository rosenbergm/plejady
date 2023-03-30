defmodule PlejadyWeb.Header do
  @moduledoc """
  Component library for the app header.
  """
  use PlejadyWeb, :verified_routes

  use Phoenix.Component

  attr :title, :string, required: true
  attr :current_user, :map, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :actions

  @doc """
  A LiveComponent that renders the app header.
  """
  def app_header(assigns) do
    ~H"""
    <header class="app-header flex flex-col justify-center gap-1 p-4 lg:py-0 lg:h-24 lg:px-16 lg:flex-row lg:items-center lg:justify-between">
      <div class="flex items-center flex-row justify-between md:gap-16 md:justify-start">
        <.link navigate={~p"/"}>
          <img src="/images/logo_small.svg" />
        </.link>

        <p class="text-sm font-medium tracking-tight">
          <%= @title %>
        </p>
      </div>

      <section class="flex gap-2 items-center flex-wrap lg:gap-8">
        <.link
          href={~p"/auth/logout"}
          method="delete"
          class="text-sm font-medium tracking-tight underline hover:no-underline"
        >
          Odhlásit se
        </.link>

        <p class="text-sm font-medium tracking-tight">
          Přihlášen/a jako <b><%= @current_user.email %></b>
        </p>

        <%= render_slot(@actions) %>
      </section>
    </header>
    """
  end
end

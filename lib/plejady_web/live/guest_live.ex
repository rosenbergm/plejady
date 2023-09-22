defmodule PlejadyWeb.GuestLive do
  @moduledoc false

  use PlejadyWeb, :live_view

  alias Plejady.Accounts.Guest
  alias Plejady.{Accounts, Config}

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlejadyWeb.Endpoint.subscribe("refresher")

    free_places = Accounts.get_free_guest_places()

    config = Config.get_config()

    {:ok,
     assign(socket,
       free_places: free_places,
       config: config,
       form: to_form(Guest.new(%Guest{}))
     )}
  end

  def render(assigns) do
    ~H"""
    <main class="w-full h-full flex flex-col items-center justify-center gap-3 text-center space-y-6 px-6 mx-auto max-w-lg">
      <.flash_group flash={@flash} />
      <img src="/images/logo.svg" />

      <article class="space-y-4">
        <h3 class="text-lg font-semibold text-primary">Přihlášení pro hosty</h3>

        <p class="text-sm font-medium tracking-tight max-w-xs mx-auto">
          Pro přihlášení hostů stačí zadat e-mailovou adresu a odeslat ji. Budeme s vámi počítat.
        </p>

        <p class="text-sm font-medium tracking-tight">
          Upozorňujeme však, že kapacita je <%= @config.guest_capacity %> míst.
          <b>Zbývá už jen <%= @free_places %> míst.</b>
        </p>

        <.form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          class="flex sm:items-start flex-col sm:flex-row gap-4"
        >
          <.input
            field={@form[:email]}
            placeholder="v.havel@gmail.com"
            type="email"
            disabled={@free_places == 0 || !@config.is_open || @config.has_ended}
          />

          <.button
            class="flex-1 sm:flex-none"
            disabled={@free_places == 0 || !@config.is_open || @config.has_ended}
          >
            Odeslat
          </.button>
        </.form>

        <p :if={@free_places == 0} class="text-sm font-medium tracking-tight max-w-xs mx-auto">
          Bohužel jsou již všechna místa obsazena!
        </p>
        <p
          :if={!@config.is_open && !@config.timed_release && !@config.has_ended}
          class="text-sm font-medium tracking-tight max-w-xs mx-auto"
        >
          Ještě se nemůžete přihlásit.
        </p>
        <p
          :if={!@config.is_open && @config.timed_release}
          class="text-sm font-medium tracking-tight max-w-xs mx-auto"
        >
          Ještě se nemůžete přihlásit. Přihlašování začíná <%= Plejady.Datetime.format_datetime(
            @config.timed_release
          ) %>.
        </p>
        <p :if={@config.has_ended} class="text-sm font-medium tracking-tight max-w-xs mx-auto">
          Přihlašování bylo ukončeno!
        </p>
      </article>
    </main>
    """
  end

  def handle_event("validate", %{"guest" => params}, socket) do
    form =
      %Guest{}
      |> Guest.new(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"guest" => user_params}, socket) do
    free_places = Accounts.get_free_guest_places()

    if free_places == 0 do
      {:noreply,
       socket
       |> put_flash(:error, "Bohužel jsou již všechna místa obsazena!")
       |> redirect(to: ~p"/")}
    else
      case Accounts.create_guest(user_params) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Host úspěšně zapsán!")
           |> redirect(to: "/")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    end
  end

  def handle_info(%{event: "refresh"}, socket) do
    config = Config.get_config()

    {:noreply,
     socket
     |> push_redirect(to: ~p"/guests")
     |> put_flash(
       :info,
       if config.has_ended do
         "Přihlašování hostů bylo ukončeno!"
       else
         "Přihlašování hostů bylo spuštěno!"
       end
     )}
  end
end

defmodule PlejadyWeb.AdminSettingsLive.TimedRelease do
  @moduledoc false

  use PlejadyWeb, :live_component

  alias Plejady.CacheInitiator
  alias Plejady.Config
  alias Plejady.Config.Schema

  def mount(socket) do
    config = Config.get_config()

    {:ok, assign(socket, config: config) |> assign_form(Config.Schema.changeset(config))}
  end

  def render(assigns) do
    ~H"""
    <article class="px-4 lg:px-16 space-y-6">
      <h2 class="font-bold text-lg">Časované spuštění a hosté ↓</h2>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="timed-release-form"
        class="flex sm:items-end flex-col sm:flex-row gap-4 max-w-[50rem]"
      >
        <.input
          field={@form[:timed_release]}
          type="datetime-local"
          label="Spuštění proběhne v tento čas (český čas)"
          phx-hook="LocalTime"
        />

        <.input
          field={@form[:guest_capacity]}
          type="number"
          label="Maximální počet hostů"
          placeholder="30"
        />

        <.button class="flex-1 sm:flex-none" phx-disable-with="Ukládám...">Uložit</.button>
      </.form>

      <h6 class="text-red-400 font-bold">Danger zone ↓</h6>

      <div class="flex sm:items-center flex-col sm:flex-row gap-4 max-w-[50rem] p-2 sm:p-4 rounded ring-4 ring-red-400/50 hover:ring-red-400 transition">
        <.button
          :if={!@config.is_open}
          phx-target={@myself}
          data-confirm="Jste si opravdu jisti, že chcete přihlašování otevřít nyní?"
          phx-click="open_now"
        >
          Otevřít nyní
        </.button>
        <.button
          :if={@config.is_open}
          phx-target={@myself}
          data-confirm="Jste si opravdu jisti, že chcete přihlašování uzavřít nyní?"
          phx-click="close_now"
        >
          Uzavřít nyní
        </.button>

        <p>
          <b class="font-black text-lg">POZOR:</b>
          Na toto tlačítko opatrně, systém totiž <%= if @config.is_open do
            "uzavře"
          else
            "otevře"
          end %> ihned.
        </p>
      </div>
    </article>
    """
  end

  def handle_event(
        "validate",
        %{"schema" => params},
        socket
      ) do
    changeset =
      %Schema{}
      |> Schema.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "save",
        %{"schema" => params},
        socket
      ) do
    config = Schema.from_changeset(params)
    Config.set_config(config)

    if Process.whereis(Plejady.TimedRelease) do
      GenServer.cast(Plejady.TimedRelease, {:update, config.timed_release})
    else
      GenServer.start(Plejady.TimedRelease, config.timed_release, name: Plejady.TimedRelease)
    end

    {
      :noreply,
      socket
      |> put_flash(:info, "Nastavení úspěšně uloženo!")
      |> push_redirect(to: ~p"/admin/settings")
    }
  end

  def handle_event("open_now", _params, socket) do
    CacheInitiator.initiate()

    %Schema{
      is_open: true,
      timed_release: nil
    }
    |> Config.set_config()

    PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "refresh", nil)

    {
      :noreply,
      socket
      |> put_flash(:info, "Přihlašování bylo spuštěno!")
      |> push_redirect(to: ~p"/admin/settings")
    }
  end

  def handle_event("close_now", _params, socket) do
    %Schema{
      is_open: false,
      timed_release: nil
    }
    |> Config.set_config()

    PlejadyWeb.Endpoint.broadcast_from(self(), "presentations", "refresh", nil)

    {
      :noreply,
      socket
      |> put_flash(:info, "Přihlašování bylo uzavřeno!")
      |> push_redirect(to: ~p"/admin/settings")
    }
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

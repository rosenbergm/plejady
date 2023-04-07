defmodule PlejadyWeb.AdminSettingsLive.AdminManagement do
  @moduledoc false

  use PlejadyWeb, :live_component

  alias Plejady.Accounts
  alias Plejady.Accounts.SuggestedAdmin
  alias Plejady.Accounts.User.Promotion

  @impl true
  def mount(socket) do
    admins = Accounts.get_admins()
    suggested_admins = SuggestedAdmin.get()

    {:ok,
     socket
     |> stream(:admins, admins)
     |> stream(:suggested_admins, suggested_admins)
     |> assign(promotion: %Promotion{})
     |> assign_form(:form, Promotion.changeset())
     |> assign_form(:transfer, Promotion.changeset())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <article class="px-4 lg:px-16 space-y-6">
      <h2 class="font-bold text-lg">Seznam administrátorstva ↓</h2>

      <.table id="admins" rows={@streams.admins}>
        <:col :let={{_id, admin}} label="Jméno">
          <.icon :if={admin.role == :lead} name="hero-building-library" class="w-4 h-4" />
          <%= admin.given_name %> <%= admin.last_name %>
          <span :if={admin.id == @current_user.id}>(já)</span>
        </:col>
        <:col :let={{_id, admin}} label="E-mail">
          <%= admin.email %>
        </:col>

        <:action :let={{id, admin}}>
          <.link
            :if={admin.role != :lead || @current_user.id != admin.id}
            phx-click={JS.push("delete", value: %{id: admin.id}) |> hide("##{id}")}
            data-confirm={"Opravdu chcete odebrat administrátora #{admin.given_name} #{admin.last_name}?"}
            class="underline hover:no-underline hover:text-primary"
          >
            Odebrat
          </.link>
        </:action>
      </.table>

      <h2 class="font-bold text-lg">Navržení administrátoři ↓</h2>

      <.table id="suggested_admins" rows={@streams.suggested_admins}>
        <:col :let={{_id, admin}} label="E-mail"><%= admin.email %></:col>

        <:action :let={{id, admin}}>
          <.link
            phx-click={
              JS.push("delete-suggested", target: @myself, value: %{id: admin.id}) |> hide("##{id}")
            }
            data-confirm={"Opravdu chcete odebrat navrženého administrátora #{admin.email}?"}
            class="underline hover:no-underline hover:text-primary"
          >
            Odebrat
          </.link>
        </:action>
      </.table>

      <h2 class="font-bold text-lg">Přidat nebo navrhnout administrátora ↓</h2>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="promotion-form"
        class="flex sm:items-end flex-col sm:flex-row gap-4 max-w-[50rem]"
      >
        <.input
          field={@form[:email]}
          type="email"
          label="E-mail nového administrátora"
          placeholder="polouckova.karla@student.alej.cz"
        />

        <.button class="flex-1 sm:flex-none" phx-disable-with="Ukládám...">Uložit</.button>
      </.form>

      <h6 class="text-red-400 font-bold">Danger zone ↓</h6>

      <div
        :if={@current_user.role == :lead}
        class="flex flex-col gap-4 relative max-w-[50rem] p-2 sm:p-4 rounded ring-4 ring-red-400/50 hover:ring-red-400 transition"
      >
        <h6 class="text-md font-bold pr-6">
          Předat roli hlavního administrátora ↓
        </h6>

        <.tooltip class="absolute top-2 right-2 sm:top-4 sm:right-4">
          <p class="text-sm font-semibold text-primary">
            Předání hlavního administrátora znamená, že ztratíte veškerou kontrolu nad ostatními administrátory a nad nastavování přednášek. Sami budete nastaveni jako běžný administrátor.
          </p>
        </.tooltip>

        <.form
          for={@transfer}
          phx-target={@myself}
          phx-change="validate_transfer"
          phx-submit="save_transfer"
          id="transfer-form"
          class="flex sm:items-end flex-col sm:flex-row gap-4 max-w-[50rem]"
        >
          <.input
            field={@transfer[:email]}
            id="transfer-email"
            type="email"
            label="E-mail nového hlavního administrátora"
            placeholder="dobrenka.kateryna@student.alej.cz"
          />

          <.button
            class="flex-1 sm:flex-none"
            data-confirm="Opravdu chcete přenést své hlavní administrátorství? Ztratíte tím veškerou kontrolu nad ostatními administrátory!"
            phx-disable-with="Ukládám..."
          >
            Uložit
          </.button>
        </.form>
      </div>
    </article>
    """
  end

  @impl true
  def handle_event("validate", %{"promotion" => params}, socket) do
    changeset =
      socket.assigns.promotion
      |> Promotion.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, :form, changeset)}
  end

  def handle_event("save", %{"promotion" => params}, socket) do
    case Promotion.promote(params) do
      {:modified, user} ->
        {:noreply,
         socket
         |> stream_insert(:admins, user)
         |> assign_form(:form, Promotion.changeset())
         |> put_flash(:info, "Uživatel byl povýšen na administrátora.")
         |> push_patch(to: ~p"/admin/settings")}

      {:created, suggested_admin} ->
        {:noreply,
         socket
         |> stream_insert(:suggested_admins, suggested_admin)
         |> assign_form(:form, Promotion.changeset())
         |> put_flash(:info, "Uživatel byl přidán do seznamu návrhů na administrátory.")
         |> push_patch(to: ~p"/admin/settings")}
    end
  end

  @impl true
  def handle_event("validate_transfer", %{"promotion" => params}, socket) do
    changeset =
      socket.assigns.promotion
      |> Promotion.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, :transfer, changeset)}
  end

  def handle_event(
        "save_transfer",
        %{"promotion" => params},
        %{assigns: %{current_user: user}} = socket
      ) do
    case Accounts.transfer_admin(user.id, params["email"]) do
      %{to: {:ok, _update}} = _transfer ->
        {:noreply,
         socket
         |> assign_form(:transfer, Promotion.changeset())
         |> put_flash(:info, "Hlavní administrátorství bylo předáno.")
         |> push_redirect(to: ~p"/admin/settings")}

      _ ->
        {:noreply,
         socket
         |> assign_form(:transfer, Promotion.changeset())
         |> put_flash(
           :error,
           "Uživatel, kterému chcete předat hlavní administrátorství, neexistuje."
         )
         |> push_redirect(to: ~p"/admin/settings")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Accounts.strip_off_admin(id)

    {:noreply, stream_delete(socket, :admins, admin)}
  end

  @impl true
  def handle_event("delete-suggested", %{"id" => id}, socket) do
    admin = Accounts.delete_suggested_admin(id)

    {:noreply, stream_delete(socket, :suggested_admins, admin)}
  end

  defp assign_form(socket, key, %Ecto.Changeset{} = changeset) when is_atom(key) do
    assign(socket, key, to_form(changeset))
  end
end

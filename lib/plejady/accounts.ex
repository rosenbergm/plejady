defmodule Plejady.Accounts do
  @moduledoc """
  Provides logic for managing accounts. This includes users, guests, admins, etc.
  """
  alias Plejady.{Config, Repo}
  alias Plejady.Accounts.{Guest, User, SuggestedAdmin}

  import Ecto.Query

  @doc """
  Creates a new guest.

  > This is a database action.
  """
  def create_guest(params) do
    %Guest{}
    |> Guest.new(params)
    |> Repo.insert()
  end

  @doc """
  Fetches a number of free guest places.
  """
  def get_free_guest_places do
    Repo.aggregate(Guest, :count)
    |> Kernel.-(Config.get_config().guest_capacity)
    |> abs()
  end

  @doc """
  Fetches a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Fetches all admins.
  """
  def get_admins do
    Repo.all(from u in User, where: u.role != :user, select: u)
  end

  @doc """
  Strips off admin rights from the user with the given id.

  > This is a database action.
  """
  def strip_off_admin(id) do
    from(u in User, where: u.id == ^id, select: u)
    |> User.strip_off_admin()
  end

  @doc """
  Deletes a suggested admin by its id.

  > This is a database action.
  """
  def delete_suggested_admin(id) do
    {:ok, admin} =
      Repo.get(SuggestedAdmin, id)
      |> Repo.delete()

    admin
  end

  @doc """
  Checks if there are any other users registered. If not, this function returns `true`.
  """
  def first_user? do
    Repo.aggregate(User, :count) == 0
  end

  @doc """
  Transfers the admin lead role to another user (specified by their email).

  > This is a database action.
  """
  def transfer_admin(me, to_email) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:from_user, from(u in User, where: u.id == ^me, select: u))
    |> Ecto.Multi.update(:from, fn %{from_user: user} ->
      Ecto.Changeset.change(user, role: :user)
    end)
    |> Ecto.Multi.one(:to_user, from(u in User, where: u.email == ^to_email, select: u))
    |> Ecto.Multi.update(:to, fn %{to_user: user} ->
      Ecto.Changeset.change(user, role: :lead)
    end)
    |> Repo.transaction()
  rescue
    _ ->
      :error
  end
end

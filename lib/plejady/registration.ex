defmodule Plejady.Registration do
  @moduledoc """
  Provides the model and logic for registrations.
  """
  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Plejady.{Repo, Registration}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "registrations" do
    belongs_to :user, Plejady.Accounts.User
    belongs_to :presentation, Plejady.Presentation

    timestamps()
  end

  @doc """
  Creates a new changeset based on the `registration` struct and `params`.
  """
  def changeset(registration, params \\ %{}) do
    registration
    |> cast(params, [:user_id, :presentation_id])
    |> validate_required([:user_id, :presentation_id])
  end

  @doc """
  Creates a new registration and inserts it into the database.

  > This is a database action.
  """
  def new(presentation_id, user_id) do
    %Registration{}
    |> changeset(%{presentation_id: presentation_id, user_id: user_id})
  end

  @doc """
  Moves a registration from one presentation to another. Arguments `from` and `to` are presentation IDs.

  > This is a database action.
  """
  def move(from, to, user_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete,
      from(r in Plejady.Registration,
        where: r.presentation_id == ^from and r.user_id == ^user_id
      )
    )
    |> Ecto.Multi.insert(:insert, new(to, user_id))
    |> Repo.transaction()
  end
end

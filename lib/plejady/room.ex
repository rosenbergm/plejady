defmodule Plejady.Room do
  @moduledoc """
  Provides the model and logic for rooms.
  """
  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Plejady.{Repo, Room}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rooms" do
    field :name, :string
    field :capacity, :integer

    timestamps()
  end

  @doc """
  Creates a new changeset based on the `room` struct and `params`.
  """
  def changeset(room, params \\ %{}) do
    room
    |> cast(params, [:name, :capacity])
    |> validate_required([:name, :capacity])
    |> validate_number(:capacity, greater_than: 0)
  end

  @doc """
  Creates a new room and inserts it into the database.

  > This is a database action.
  """
  def create(params \\ %{}) do
    %Room{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Updates a room with the included params in the database.

  > This is a database action.
  """
  def update(room, params \\ %{}) do
    room
    |> changeset(params)
    |> Repo.update()
  end

  @doc """
  Returns a list of all rooms.
  """
  def all do
    Repo.all(from r in Room, order_by: [asc: r.name], select: r)
  end

  @doc """
  Fetch a room by id.
  """
  def get!(id) do
    Repo.get!(Room, id)
  end

  @doc """
  Deletes a room by id.

  > This is a database action.
  """
  def delete(id) do
    Room.get!(id)
    |> Repo.delete()
  end
end

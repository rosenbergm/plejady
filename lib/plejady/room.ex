defmodule Plejady.Room do
  use Ecto.Schema

  import Ecto.Changeset

  alias Plejady.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rooms" do
    field :name, :string
    field :capacity, :integer

    timestamps()
  end

  def changeset(room, params \\ %{}) do
    room
    |> cast(params, [:name, :capacity])
    |> validate_required([:name, :capacity])
    |> validate_number(:capacity, greater_than: 0)
  end

  def create_room(room, params \\ %{}) do
    room
    |> changeset(params)
    |> Repo.insert()
  end
end

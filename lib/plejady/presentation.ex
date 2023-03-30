defmodule Plejady.Presentation do
  @moduledoc """
  Provides the model and logic for presentations.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plejady.{Repo, Presentation, Room, Timeblock, Registration}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "presentations" do
    field :presenter, :string
    field :description, :string

    field :capacity, :integer

    belongs_to :room, Plejady.Room
    belongs_to :timeblock, Plejady.Timeblock

    has_many :registrations, Plejady.Registration

    timestamps()
  end

  @doc """
  Creates a new changeset based on the `presentation` struct and `params`.
  """
  def changeset(presentation, params \\ %{}) do
    presentation
    |> cast(params, [:presenter, :description, :capacity, :room_id, :timeblock_id])
    |> validate_required([:presenter, :description, :room_id, :timeblock_id])
    |> validate_number(:capacity, greater_than: 0)
  end

  @doc """
  Creates a new presentation and inserts it into the database.

  > This is a database action.
  """
  def create(presentation, params \\ %{}) do
    presentation
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Updates a new presentation and updates it in the database.

  > This is a database action.
  """
  def update(presentation, params \\ %{}) do
    presentation
    |> changeset(params)
    |> Repo.update()
  end

  @doc """
  Fetches all presentations from the database.
  """
  def all do
    Repo.all(Presentation)
  end

  @doc """
  Fetches all presentations from the database, preloading their room, timeblock and registrations.
  """
  def all_preloaded do
    timeblocks = from(t in Timeblock, order_by: [asc: t.block_start], select: t)
    rooms = from(r in Room, order_by: [asc: r.name], select: r)
    registrations = from(r in Registration, preload: [:user], select: r)

    from(p in Presentation,
      select: p,
      preload: [room: ^rooms, timeblock: ^timeblocks, registrations: ^registrations]
    )
    |> Repo.all()
  end

  @doc """
  Fetches a presentation by its ID from the database.
  """
  def get!(id) do
    Repo.get!(Presentation, id)
  end

  @doc """
  Deletes a presentation from the database.

  > This is a database action.
  """
  def delete(id) do
    Presentation.get!(id)
    |> Repo.delete()
  end
end

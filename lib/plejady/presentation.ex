defmodule Plejady.Presentation do
  use Ecto.Schema

  import Ecto.Changeset

  alias Plejady.Repo

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

  def changeset(presentation, params \\ %{}) do
    presentation
    |> cast(params, [:presenter, :description, :capacity, :room_id, :timeblock_id])
    |> validate_required([:presenter, :description, :room_id, :timeblock_id])
  end

  def create_presentation(presentation, params \\ %{}) do
    presentation
    |> changeset(params)
    |> Repo.insert()
  end

  def update_presentation(changeset, params \\ %{}) do
    changeset
    |> changeset(params)
    |> Repo.update()
  end
end

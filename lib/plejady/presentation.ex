defmodule Plejady.Presentation do
  use Ecto.Schema

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
end

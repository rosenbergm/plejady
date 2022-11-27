defmodule Plejady.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :gid, :string
    field :email, :string
    field :given_name, :string
    field :last_name, :string
    field :is_admin, :boolean, default: false

    timestamps()
  end
end

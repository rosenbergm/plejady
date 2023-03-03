defmodule Plejady.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Plejady.Repo

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

  def make_user_admin(user) do
    user
    |> change(is_admin: true)
    |> Repo.update()
  end

  defmodule Promotion do
    use Ecto.Schema

    @mail_regex ~r/^[A-Za-z0-9._%+-]+@student.alej.cz$/

    embedded_schema do
      field :email, :string
    end

    def changeset do
      %__MODULE__{}
      |> change()
    end

    def changeset(params) do
      %__MODULE__{}
      |> cast(params, [:email])
      |> validate_required([:email])
      |> validate_format(:email, @mail_regex, message: "Email musí končit @student.alej.cz!")
    end
  end
end

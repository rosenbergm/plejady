defmodule Plejady.SuggestedAdmin do
  use Ecto.Schema

  import Ecto.Changeset

  alias Plejady.Repo

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@student.alej.cz$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "suggested_admins" do
    field :email, :string

    timestamps()
  end

  def changeset(admin, params \\ %{}) do
    admin
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, @mail_regex, message: "Email musí končit @student.alej.cz!")
  end

  def create(params \\ %{}) do
    %Plejady.SuggestedAdmin{}
    |> changeset(params)
    |> Repo.insert()
  end
end

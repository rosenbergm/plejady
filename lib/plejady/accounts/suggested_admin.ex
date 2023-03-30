defmodule Plejady.Accounts.SuggestedAdmin do
  @moduledoc """
  Provides logic for suggested admins (users that will automatically become admins).
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Plejady.Repo
  alias Plejady.Accounts.SuggestedAdmin

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@(student.)?alej.cz$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "suggested_admins" do
    field :email, :string

    timestamps()
  end

  @doc """
  Creates a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, @mail_regex, message: "Email musí končit @student.alej.cz!")
  end

  @doc """
  Creates a new suggested admin and inserts it into the database.

    > This is a database action.
  """
  def create(params \\ %{}) do
    %SuggestedAdmin{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Returns the list of all suggested admins.

    > This is a database action.
  """
  def get do
    Repo.all(from s in SuggestedAdmin, select: s)
  end

  @doc """
  Returns the suggested admin with the given email.

    > This is a database action.
  """
  def get_by_email(email) do
    Repo.get_by(SuggestedAdmin, email: email)
  end

  @doc """
  Deletes the suggested admin with the given email.

    > This is a database action.
  """
  def delete_by_email(email) do
    Repo.get(SuggestedAdmin, email: email)
    |> Repo.delete()
  end
end

defmodule Plejady.Accounts.Guest do
  @moduledoc """
  Provides logic for guest users (users whose email is not a student's email).
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "absolvents" do
    field :email, :string

    timestamps()
  end

  @doc """
  Creates a changeset based on the `guest` struct and `params`.
  """
  def new(guest, params \\ %{}) do
    guest
    |> cast(params, [:email])
    |> validate_required([:email], message: "Musíte vyplnit e-mail!")
    |> validate_if_not_student(:email)
  end

  @doc """
  Validates if the given field is not a student's email.
  """
  def validate_if_not_student(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, value ->
      if String.contains?(value, "@student.alej.cz") do
        [{field, "E-mail nesmí být školní!"}]
      else
        []
      end
    end)
  end
end

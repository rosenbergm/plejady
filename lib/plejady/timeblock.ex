defmodule Plejady.Timeblock do
  @moduledoc """
  Provides the model and logic for timeblocks.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias Plejady.{Repo, Timeblock}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "timeblocks" do
    field :block_start, :time
    field :block_end, :time

    timestamps()
  end

  @doc """
  Creates a new changeset based on the `timeblock` struct and `params`.
  """
  def changeset(timeblock, params \\ %{}) do
    timeblock
    |> cast(params, [:block_start, :block_end])
    |> validate_required([:block_start, :block_end])
  end

  @doc """
  Creates a new timeblock and inserts it into the database.

  > This is a database action.
  """
  def create(params \\ %{}) do
    %Timeblock{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Updates a timeblock with the included params in the database.
  """
  def update(timeblock, params \\ %{}) do
    timeblock
    |> changeset(params)
    |> Repo.update()
  end

  def format_time(%Time{} = time) do
    Plejady.Cldr.DateTime.to_string!(time, format: "hh:mm")
  end

  @doc """
  Returns a list of all timeblocks.
  """
  def all do
    Repo.all(from t in Timeblock, order_by: [asc: t.block_start], select: t)
  end

  @doc """
  Returns a single timeblock by id. If no timeblock is found, returns `nil`.
  """
  def get!(id) do
    Repo.get!(Timeblock, id)
  end

  @doc """
  Deletes a timeblock by id.

  > This is a database action.
  """
  def delete(id) do
    Timeblock.get!(id)
    |> Repo.delete()
  end
end

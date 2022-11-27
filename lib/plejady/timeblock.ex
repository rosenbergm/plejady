defmodule Plejady.Timeblock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "timeblocks" do
    field :block_start, :time
    field :block_end, :time

    timestamps()
  end

  def new(params) do
    %Plejady.Timeblock{}
    |> cast(params, [:block_start, :block_end])
    |> validate_required([:block_start, :block_end])
  end

  def edit(timeblock, block_start, block_end) do
    timeblock
    |> change(block_start: block_start)
    |> change(block_end: block_end)
    |> validate_required([:block_start, :block_end])
  end

  def format_time(%Time{hour: hour, minute: minute}) do
    if minute == 0 do
      "#{hour}:00"
    else
      "#{hour}:#{minute}"
    end
  end
end

defmodule Plejady.Repo.Migrations.Constratins do
  use Ecto.Migration

  def change do
    create unique_index(:presentations, [:room_id, :timeblock_id])
  end
end

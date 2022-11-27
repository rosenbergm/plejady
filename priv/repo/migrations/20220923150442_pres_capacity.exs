defmodule Plejady.Repo.Migrations.PresCapacity do
  use Ecto.Migration

  def change do
    alter table(:presentations) do
      add :capacity, :integer, null: true
    end
  end
end

defmodule Plejady.Repo.Migrations.Guests do
  use Ecto.Migration

  def change do
    create table(:absolvents, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :email, :string, null: false

      timestamps()
    end
  end
end

defmodule Plejady.Repo.Migrations.Absolvents do
  use Ecto.Migration

  def change do
    create table(:absolvents, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:absolvents, [:email])
  end
end

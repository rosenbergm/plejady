defmodule Plejady.Repo.Migrations.SuggestedAdmins do
  use Ecto.Migration

  def change do
    create table(:suggested_admins, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :email, :string, null: false

      timestamps()
    end
  end
end

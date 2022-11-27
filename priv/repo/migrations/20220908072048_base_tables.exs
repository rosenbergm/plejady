defmodule Plejady.Repo.Migrations.BaseTables do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :gid, :string, null: false
      add :email, :string, null: false
      add :given_name, :string, null: false
      add :last_name, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email, :gid])

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :token, :binary, null: false
      add :context, :string, null: false

      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:timeblocks, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :block_start, :time, null: false
      add :block_end, :time, null: false

      timestamps()
    end

    create table(:rooms, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string, null: false
      add :capacity, :integer, null: false

      timestamps()
    end

    create table(:presentations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :presenter, :string, null: false
      add :description, :string, null: false

      add :room_id, references(:rooms, on_delete: :delete_all, type: :uuid), null: false
      add :timeblock_id, references(:timeblocks, on_delete: :delete_all, type: :uuid), null: false

      timestamps()
    end

    create table(:registrations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      add :presentation_id, references(:presentations, on_delete: :delete_all, type: :uuid),
        null: false

      timestamps()
    end

    # TODO: Add unique index
  end
end

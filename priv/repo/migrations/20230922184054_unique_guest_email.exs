defmodule Plejady.Repo.Migrations.UniqueGuestEmail do
  use Ecto.Migration

  def change do
    create unique_index(:absolvents, [:email])
  end
end

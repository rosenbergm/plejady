defmodule Plejady.Registration do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Plejady.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "registrations" do
    belongs_to :user, Plejady.User
    belongs_to :presentation, Plejady.Presentation

    timestamps()
  end

  def new(presentation_id, user_id) do
    %Plejady.Registration{}
    |> cast(%{presentation_id: presentation_id, user_id: user_id}, [:user_id, :presentation_id])
    |> validate_required([:user_id, :presentation_id])
    |> Repo.insert!()
  end

  def delete(presentation_id, user_id) do
    from(r in Plejady.Registration,
      where: r.presentation_id == ^presentation_id and r.user_id == ^user_id
    )
    |> Repo.delete_all()
  end
end

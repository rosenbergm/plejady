defmodule Plejady.Accounts.User do
  @moduledoc """
  Provides logic for managing users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Plejady.Repo
  alias Plejady.Accounts
  alias Plejady.Accounts.SuggestedAdmin
  alias Plejady.Accounts.User
  alias PLejady.Accounts.User.Promotion

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :gid, :string
    field :email, :string
    field :given_name, :string
    field :last_name, :string

    field :role, Ecto.Enum, values: [:user, :admin, :lead], default: :user

    timestamps()
  end

  @doc """
  Gives the given user admin rights.

  > This is a database action.
  """
  def make_user_admin(user) do
    user
    |> change(role: :admin)
    |> Repo.update()
  end

  @doc """
  Removes admin rights from the given user.

  > This is a database action.
  """
  def strip_off_admin(user) do
    user
    |> change(role: :user)
    |> Repo.update()
  end

  defmodule Promotion do
    @moduledoc """
    Provides logic for promoting users.
    """
    use Ecto.Schema

    @mail_regex ~r/^[A-Za-z0-9._%+-]+@(student.)?alej.cz$/

    embedded_schema do
      field :email, :string
    end

    @doc """
    Creates an empty changeset
    """
    def changeset do
      %Promotion{}
      |> change()
    end

    @doc """
    Creates a new changeset based on the `promotion` struct and `params`.
    """
    def changeset(promotion, params) do
      promotion
      |> cast(params, [:email])
      |> validate_required([:email])
      |> validate_format(:email, @mail_regex, message: "Email musí končit @student.alej.cz!")
    end

    @doc """
    Returns the completed Promotion struct regardless of changeset validity.

    In our case it doesn't matter if the changeset is valid or not, because we validate the integrity of the data during form validation.
    """
    def create(params \\ %{}) do
      %Promotion{}
      |> changeset(params)
      |> apply_changes()
    end

    @doc """
    Either promotes the user or creates a new suggested admin.

    > This is a database action.
    """
    def promote(params \\ %{}) do
      promotion = Promotion.create(params)

      if user = Accounts.get_user_by_email(promotion.email) do
        {:ok, user} = User.make_user_admin(user)

        {:modified, user}
      else
        {:ok, suggested_admin} = SuggestedAdmin.create(params)

        {:created, suggested_admin}
      end
    end
  end
end

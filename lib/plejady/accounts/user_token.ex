defmodule Plejady.Accounts.UserToken do
  @moduledoc """
  Provides logic for managing user tokens.
  """
  use Ecto.Schema
  import Ecto.Query

  alias Plejady.Accounts.UserToken

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "users_tokens" do
    field :token, :binary
    field :context, :binary

    belongs_to :user, Plejady.Accounts.User, type: :binary_id

    timestamps(updated_at: false)
  end

  @doc """
  Builds a session token bound to the given user.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(32)

    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  @doc """
  Builds a query for the given session token with correct validity checking.
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Builds a query for the given token and context.
  """
  def token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end

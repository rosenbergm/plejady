defmodule Plejady.Accounts.Token do
  @moduledoc """
  Utilities for managing user tokens.
  """
  alias Plejady.{Repo}
  alias Plejady.Accounts.UserToken

  @doc """
  Generates a new session token for the given user and inserts it into the database.

    > This is a database action.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)

    Repo.insert!(user_token)

    token
  end

  @doc """
  Returns the user with the given session token.

    > This is a database action.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    Repo.one(query)
  end

  @doc """
  Deletes the session token from the database.

    > This is a database action.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end
end

defmodule Plejady.Token do
  alias Plejady.{Repo, UserToken}

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)

    Repo.insert!(user_token)

    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    Repo.one(query)
  end

  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end
end

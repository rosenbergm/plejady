defmodule Plejady.Repo do
  @moduledoc """
  The Ecto repository for this application.

  > The functions here are automatically generated `use Ecto.Repo`.
  """

  use Ecto.Repo,
    otp_app: :plejady,
    adapter: Ecto.Adapters.Postgres
end

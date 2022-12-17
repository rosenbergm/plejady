defmodule Plejady.Repo do
  use Ecto.Repo,
    otp_app: :plejady,
    adapter: Ecto.Adapters.Postgres
end

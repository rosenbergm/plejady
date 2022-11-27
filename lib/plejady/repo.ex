defmodule Plejady.Repo do
  use Ecto.Repo,
    otp_app: :plejady,
    adapter: if(Mix.env() == :dev, do: Ecto.Adapters.SQLite3, else: Ecto.Adapters.Postgres)
end

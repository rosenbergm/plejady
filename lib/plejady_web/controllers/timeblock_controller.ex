defmodule PlejadyWeb.TimeblockController do
  use PlejadyWeb, :controller

  alias Plejady.{Registration, Repo, Timeblock}

  import Ecto.Query

  def index(conn, _params) do
    timeblocks = Repo.all(Timeblock)

    user_id = "0f941239-b75c-408d-977b-a99313e62ce0"

    from(r in Registration,
      where: r.user_id == ^user_id,
      preload: [:presentation],
      select: r
    )
    |> Repo.all()
    |> Enum.map(& &1.presentation)
    |> IO.inspect()

    render(conn, "index.html", timeblocks: timeblocks)
  end
end

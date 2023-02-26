defmodule PlejadyWeb.AdminController do
  use PlejadyWeb, :controller

  alias Plejady.{Presentation, Repo, Room, Timeblock, User}
  import Ecto.Query

  def index(conn, _params) do
    timeblocks = Repo.all(Timeblock) |> IO.inspect(label: "Timeblocks:")
    rooms = Repo.all(Room) |> IO.inspect(label: "Rooms:")
    presentations = Repo.all(Presentation) |> IO.inspect(label: "Presentation:")

    render(conn, "index.html",
      timeblocks: timeblocks,
      rooms: rooms,
      presentations: presentations,
      user: conn.assigns.current_user
    )
  end

  def sheet(conn, _params) do
    presentations =
      from(p in Presentation,
        preload: [:room, :timeblock, registrations: [:user]],
        select: p
      )
      |> Repo.all()

    render(conn, "sheet.html",
      presentations: presentations,
      user: conn.assigns.current_user
    )
  end
end

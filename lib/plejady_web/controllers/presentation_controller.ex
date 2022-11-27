defmodule PlejadyWeb.PresentationController do
  use PlejadyWeb, :controller

  def edit(conn, %{"id" => id}) do
    conn
  end

  def update(
        conn,
        %{"presenter" => _, "description" => _, "room_id" => _, "timeblock_id" => _} = params
      ) do
    conn
  end
end

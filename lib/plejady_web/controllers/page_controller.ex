defmodule PlejadyWeb.PageController do
  @moduledoc false

  use PlejadyWeb, :controller
  import PlejadyWeb.UserAuth, only: [fetch_current_user: 2]

  alias PlejadyWeb.UserAuth

  plug :fetch_current_user

  def home(conn, _params) do
    if conn.assigns.current_user do
      UserAuth.redirect_if_user_is_authenticated(conn)
    else
      render(conn, :home, layout: false)
    end
  end

  def gdpr(conn, _params) do
    render(conn, :gdpr, layout: false)
  end
end

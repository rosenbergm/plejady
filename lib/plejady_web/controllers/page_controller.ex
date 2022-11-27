defmodule PlejadyWeb.PageController do
  use PlejadyWeb, :controller

  alias Plejady.{Absolvent, Repo}
  alias PlejadyWeb.UserAuth

  def index(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)

    render(conn, "index.html", signin_attrs: [href: oauth_google_url])
  end

  def error(conn, _params) do
    conn
    |> UserAuth.log_out_user()
  end

  def absolvent(conn, _params) do
    free_places =
      Repo.aggregate(Absolvent, :count)
      |> Kernel.-(30)
      |> abs()
      |> Integer.to_string()

    changeset = Absolvent.new(%Absolvent{})

    render(conn, "absolvent.html",
      free_places: free_places,
      changeset: changeset
    )
  end

  def gdpr(conn, _params) do
    render(conn, "gdpr.html")
  end

  def create_absolvent(conn, params) do
    IO.inspect(params)

    conn
    |> send_resp(200, "OK")
  end
end

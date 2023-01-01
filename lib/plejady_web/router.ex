defmodule PlejadyWeb.Router do
  use PlejadyWeb, :router
  import Phoenix.LiveView.Router

  import PlejadyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlejadyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :test do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlejadyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/test", PlejadyWeb do
    pipe_through [:test]

    live "/", AppLive
  end

  scope "/", PlejadyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :index
    live "/absolvent", AbsolventLive
    get "/gdpr", PageController, :gdpr
    get "/auth/google/callback", GoogleAuthController, :index
  end

  scope "/", PlejadyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/app", AppLive
    # get "/app", PageController, :error
    delete "/logout", GoogleAuthController, :log_out
  end

  scope "/admin", PlejadyWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live "/", AdminLive, :index

    get "/sheet", AdminController, :sheet
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlejadyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PlejadyWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

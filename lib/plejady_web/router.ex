defmodule PlejadyWeb.Router do
  @moduledoc false

  use PlejadyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlejadyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", PlejadyWeb do
    pipe_through :browser

    # Auth
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback

    delete "/logout", AuthController, :delete
  end

  scope "/", PlejadyWeb do
    pipe_through :browser

    # Homepage
    get "/", PageController, :home
    get "/gdpr", PageController, :gdpr

    # Guest login
    live_session :guest, layout: false do
      live "/guests", GuestLive
    end

    # App
    live_session :app, on_mount: [{PlejadyWeb.UserAuth, :ensure_authenticated}] do
      live "/app", AppLive
    end

    # Admin
    live_session :admin,
      on_mount: [
        {PlejadyWeb.UserAuth, :ensure_authenticated},
        {PlejadyWeb.UserAuth, :ensure_admin}
      ] do
      live "/admin", AdminLive.Index, :index

      live "/admin/presentation", AdminLive.Index, :new_presentation
      live "/admin/presentation/:id", AdminLive.Index, :edit_presentation

      live "/admin/room", AdminLive.Index, :new_room
      live "/admin/room/:id", AdminLive.Index, :edit_room

      live "/admin/timeblock", AdminLive.Index, :new_timeblock
      live "/admin/timeblock/:id", AdminLive.Index, :edit_timeblock

      live "/admin/settings", AdminSettingsLive.Index, :index
      live "/admin/settings/list", AdminSettingsListLive.Index, :index

      live "/admin/sheet", AdminSheetLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlejadyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:plejady, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PlejadyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

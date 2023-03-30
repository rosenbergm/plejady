defmodule Plejady.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PlejadyWeb.Telemetry,
      # Start the Ecto repository
      Plejady.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Plejady.PubSub},
      # Start Finch
      {Finch, name: Plejady.Finch},
      # Start the Endpoint (http/https)
      PlejadyWeb.Endpoint,
      # Start a worker by calling: Plejady.Worker.start_link(arg)
      # {Plejady.Worker, arg}
      {Cachex, name: :registry},
      Plejady.CacheInitiator,
      Plejady.Config
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plejady.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlejadyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

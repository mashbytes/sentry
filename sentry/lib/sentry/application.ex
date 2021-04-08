defmodule Sentry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    # camera = Application.get_env(:picam, :camera, Picam.Camera)

    # List all child processes to be supervised
    children = [
      Picam.Camera,
      Sentry.Sound.Sensor,
      # Start the endpoint when the application starts
      SentryWeb.Endpoint
      # Starts a worker by calling: Sentry.Worker.start_link(arg)
      # {Sentry.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sentry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SentryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

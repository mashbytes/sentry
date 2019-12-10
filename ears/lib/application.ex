defmodule Ears.Application do
  use Application

  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Phoenix.PubSub.PG2, name: Ears.PubSub},
      Ears.Sensor
    ]

    opts = [strategy: :one_for_one, name: Ears.Supervisor]

    if Mix.target() == :host do
      Supervisor.start_link([Ears.MockSensor | children], opts)
    else
      Supervisor.start_link(children, opts)
    end

  end

end

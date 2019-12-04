defmodule Ears.Application do
  use Application

  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Phoenix.PubSub.PG2, name: Ears.PubSub},
      Ears.Sensor
    ]

    if Mix.target() == :host do
      Ears.MockSensor
    end

    opts = [strategy: :one_for_one, name: Ears.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

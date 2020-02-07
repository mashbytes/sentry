defmodule Ears.Application do
  use Application

  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Phoenix.PubSub.PG2, name: Ears.PubSub},
      Ears.Sensor.Hardware,
      Ears.Nodes.Aggregator,
    ]

    opts = [strategy: :one_for_one, name: Ears.Supervisor]

    # if Mix.target() == :host do
    #   Supervisor.start_link([Ears.Sensor.MockHardware | children], opts)
    # else
      Supervisor.start_link(children, opts)
    # end

  end

end

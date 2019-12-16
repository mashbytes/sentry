defmodule Ears.Sensor do

  alias Ears.Sensor.PubSub
  alias Ears.Sensor.Hardware

  def subscribe() do
    PubSub.subscribe()
    Hardware.broadcast_snapshot()
  end
end

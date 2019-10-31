defmodule Ears do

  def subscribe() do
    Ears.PubSub.subscribe()
    Ears.Sensor.broadcast_snapshot()
  end

end
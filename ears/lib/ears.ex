defmodule Ears do

  def subscribe() do
    Ears.PubSub.subscribe()
  end

  def snapshot() do
    Ears.Sensor.snapshot()
  end

end


defmodule Ears do

  def subscribe() do
    Ears.PubSub.subscribe()
    Ears.PubSub.broadcast({:ears_snapshot, Ears.snapshot()})
  end

  def snapshot() do
    Ears.Sensor.snapshot()
  end

end

defmodule Ears.Events.StateChanged do
  defstruct [:previous_status]

end
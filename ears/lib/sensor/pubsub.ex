defmodule Ears.Sensor.PubSub do

  require Logger

  alias Ears.Events

  @name Ears.PubSub
  @topic "state"

  def subscribe() do
    Phoenix.PubSub.subscribe(@name, @topic)
  end

  def broadcast(:offline, since) do
    broadcast(Events.Offline.new(since))
  end

  def broadcast(:noisy, since) do
    broadcast(Events.Noisy.new(since))
  end

  def broadcast(:quiet, since) do
    broadcast(Events.Quiet.new(since))
  end

  def broadcast(message) do
    Logger.debug("Broadcasting #{inspect message}")
    Phoenix.PubSub.broadcast(@name, @topic, message)
  end

end

defmodule Ears.PubSub do
  
  require Logger

  @name __MODULE__
  @topic "state"

  def subscribe() do
    Phoenix.PubSub.subscribe(@name, @topic)
  end

  def broadcast(message) do
    Logger.debug("Broadcasting #{inspect message}")
    Phoenix.PubSub.broadcast(@name, @topic, message)
  end


end
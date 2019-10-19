defmodule Doorman.PubSub do
  
  @name __MODULE__
  @topic "nodes"

  def subscribe() do
    Phoenix.PubSub.subscribe(@name, @topic)
  end

  def broadcast(message) do
    Phoenix.PubSub.broadcast(@name, @topic, message)
  end


end
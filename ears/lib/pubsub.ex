defmodule Ears.PubSub do
  
  require Logger

  alias Ears.State
  alias Ears.Events

  @name __MODULE__
  @topic "state"

  def subscribe() do
    Phoenix.PubSub.subscribe(@name, @topic)
  end

  def broadcast(%State.Offline{} = state) do
    broadcast(Events.Offline.new(state.since))
  end

  def broadcast(%State.Noisy{} = state) do
    broadcast(Events.Noisy.new(state.since))
  end

  def broadcast(%State.Quiet{} = state) do
    broadcast(Events.Quiet.new(state.since))
  end

  def broadcast(message) do
    Logger.debug("Broadcasting #{inspect message}")
    Phoenix.PubSub.broadcast(@name, @topic, message)
  end

end
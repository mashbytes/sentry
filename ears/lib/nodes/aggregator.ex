defmodule Ears.Nodes.Aggregator do

  use GenServer

  require Logger

  alias Ears.Nodes.PubSub

  @name __MODULE__

  def start_link(state) do
    GenServer.start_link(@name, state, name: @name)
  end

  def init(_) do
    Logger.debug("Starting Aggregator")
    {:ok, :setup, 0}
  end

  def handle_info(:timeout, :setup) do
    Logger.debug("Setting up #{@name}")
    Ears.Sensor.PubSub.subscribe()

    {:noreply, %{}}
  end

  def handle_info(%Ears.Events.Noisy{} = event, state) do
    Logger.debug("Received #{inspect event}")
    key = event.node
    updated = Map.put(state, key, event)
    PubSub.broadcast_node(key, event)

    {:noreply, updated}
  end

  def handle_info(%Ears.Events.Quiet{} = event, state) do
    Logger.debug("Received #{inspect event}")
    key = event.node
    updated = Map.put(state, key, event)
    PubSub.broadcast_node(key, event)

    {:noreply, updated}
  end

  def handle_info(%Ears.Events.Offline{} = event, state) do
    Logger.debug("Received #{inspect event}")
    key = event.node
    updated = Map.put(state, key, event)
    PubSub.broadcast_node(key, event)

    {:noreply, updated}
  end

  def snapshot_node(node) do
    GenServer.call(@name, {:snapshot, node})
  end

  def list_nodes() do
    GenServer.call(@name, :list_nodes)
  end

  def handle_call({:snapshot, node}, _from, state) do
    snapshot = Map.get(state, node)
    {:reply, snapshot, state}
  end

  def handle_call(:list_nodes, _from,   state) do
    {:reply, Map.keys(state), state}
  end


end

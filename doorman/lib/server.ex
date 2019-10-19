defmodule Doorman.Server do

  @name __MODULE__
  @topic "nodes"
  use GenServer
  require Logger

  alias Phoenix.PubSub

  def start_link(_) do
    Logger.info("start_link #{@name}")
    GenServer.start_link(@name, [], name: @name)
  end

  def nodes do
    GenServer.call(@name, :nodes)
  end

  def subscribe do
    PubSub.subscribe(@name, @topic)
  end

  def init(_) do
    nodes = MapSet.new(Node.list()) |> MapSet.put(Node.self())
    Logger.info("init #{@name} with nodes #{inspect nodes}")
    :net_kernel.monitor_nodes(true)
    {:ok, nodes}
  end

  def handle_info({:nodeup, name}, nodes) do
    updated = nodes |> MapSet.put(name)
    Logger.info("Connected to #{inspect name}, nodes are now #{inspect updated}")
    # PubSub.broadcast(@name, @topic, {:node_added, name})
    {:noreply, updated}
  end

  def handle_info({:nodedown, name}, nodes) do
    updated = nodes |> MapSet.delete(name)
    Logger.info("Disconnected from #{inspect name}, nodes are now #{inspect updated}")
        # PubSub.broadcast(@name, @topic, {:node_removed, name})
    {:noreply, updated}
  end

  def handle_call(:nodes, _from, nodes) do
    {:reply, MapSet.to_list(nodes), nodes}
  end

end

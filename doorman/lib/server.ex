defmodule Doorman.Server do

  @name __MODULE__
  use GenServer
  require Logger
  alias Doorman.Events
  alias Doorman.Server

  def start_link(_) do
    Logger.info("start_link #{@name}")
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_) do
    nodes = MapSet.new(Node.list()) |> MapSet.put(Node.self())
    state = State.new(nodes)
    Logger.info("init #{@name} with nodes #{inspect nodes}")
    :net_kernel.monitor_nodes(true)
    {:ok, state}
  end

  def handle_info({:nodeup, name}, state) do
    updated = State.node_came_online(state, name)
    Logger.info("Connected to #{inspect name}, nodes are now #{inspect updated}")
    Doorman.PubSub.broadcast(NodeUp.new(name))
    broadcast_snapshot()
    {:noreply, updated}
  end

  def handle_info({:nodedown, name}, nodes) do
    updated = State.node_went_offline(state, name)
    Logger.info("Disconnected from #{inspect name}, nodes are now #{inspect updated}")
    Doorman.PubSub.broadcast(NodeDown.new(name))
    broadcast_snapshot()
    {:noreply, updated}
  end

  def broadcast_snapshot
    GenServer.call(@name, :snapshot)
  end  

  def handle_cast(:snapshot, state) do
    Doorman.PubSub.broadcast(Nodes.new(state.online, state.offline))
    {:noreply, state}
  end

end

defmodule Doorman.Server.State do
  defstruct [:online, :offline]

  def new(online \\ MapSet.new, offline \\ MapSet.new) do
    %Doorman.Server.State{online: online}
  end

  def node_came_online(self, node) do
    offline = MapSet.delete(self.offline, node)
    online = MapSet.put(self.online, node)
    Doorman.Server.State.new(online, offline)
  end

  def node_went_offline(self, node) do
    offline = MapSet.put(self.offline, node)
    online = MapSet.delete(self.online, node)
    Doorman.Server.State.new(online, offline)
  end

end
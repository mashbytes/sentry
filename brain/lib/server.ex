defmodule Brain.Server do

  @name __MODULE__
  use GenServer
  require Logger

  def start_link(options) do
    Logger.info("start_link #{@name}")
    GenServer.start_link(@name, %Brain.Server.State{}, name: @name)
  end

  def init(state) do
    Doorman.subscribe()
    Ears.subscribe()
    {:ok, state}
  end

  def handle_info({:nodes_snapshot, nodes}, state) do
    updated = state
      |> Brain.Impl.on_nodes(nodes)
    {:ok, updated}
  end

  def handle_info({:ears_snapshot, ears}, state) do
    updated = state
      |> Brain.Impl.on_update(ears)
    {:ok, updated}
  end

end

defmodule Brain.Server.State
end

defmodule Brain.State
    defstruct [:nodes]
end

defmodule Brain.State.Node
    defstruct [:name, :senses]
end

defmodule Brain.State.Node.Sense

end
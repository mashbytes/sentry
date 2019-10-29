defmodule Doorman do

  def nodes() do
    Doorman.Server.nodes()
  end

  def subscribe() do
    Doorman.PubSub.subscribe()
    Doorman.Server.broadcast_snapshot()
  end

end

defmodule Doorman.Events.NodeUp
  defstruct [:node]

  def new(node) do
    %Doorman.Events.NodeUp{node: node}
  end
end

defmodule Doorman.Events.NodeDown
  defstruct [:node]

  def new(node) do
    %Doorman.Events.NodeDown{node: node}
  end
end

defmodule Doorman.Events.Nodes
  defstruct [:online, :offline]

  def new(online, offline) do
    %Doorman.Events.Nodes{online: online, offline: offline}
  end
end


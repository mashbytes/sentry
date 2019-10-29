defmodule Doorman.Events.NodeUp do
  defstruct [:node]

  def new(node) do
    %Doorman.Events.NodeUp{node: node}
  end
end

defmodule Doorman.Events.NodeDown do
  defstruct [:node]

  def new(node) do
    %Doorman.Events.NodeDown{node: node}
  end
end

defmodule Doorman.Events.Nodes do
  defstruct [:online, :offline]

  def new(online, offline) do
    %Doorman.Events.Nodes{online: online, offline: offline}
  end
end

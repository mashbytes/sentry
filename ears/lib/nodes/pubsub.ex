defmodule Ears.Nodes.PubSub do

  require Logger

  @name __MODULE__

  def broadcast_node(node, event) when is_atom(node) do
    Phoenix.PubSub.broadcast(@name, topic(node), event)
  end

  def subscribe_node(node) when is_atom(node) do
    Phoenix.PubSub.subscribe(@name, topic(node))
  end

  defp topic(node) when is_atom(node) do
    Atom.to_string(node) <> "_sound"
  end


end

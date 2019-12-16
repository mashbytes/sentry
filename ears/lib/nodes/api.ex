defmodule Ears.Nodes do

  alias Ears.Nodes.Aggregator
  alias Ears.Nodes.PubSub

  def list() do
    Aggregator.list_nodes()
  end

  def snapshot(node) do
    Aggregator.snapshot_node(node)
  end

  def snapshot_and_subscribe(node) do
    :ok = PubSub.subscribe_node(node)
    {:ok, snapshot(node)}
  end

end

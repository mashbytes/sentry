defmodule DashboardWeb.NodesLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Nodes: <%= @nodes %>
    """
  end

  def mount(_, socket) do
    if connected?(socket) do
      Doorman.subscribe()
    end

    state = Doorman.nodes()
      |> Enum.map(fn x ->  {Atom.to_string(x), Dashboard.Node.new(x))
      |> Map.new

    {:ok, assign(socket, :nodes, state}
  end

  def handle_info({:node_added, node}, socket) do

  end

  def handle_info({:node_removed, node}, socket) do

  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp map_nodes(nodes) do
    nodes 
      |> Enum.map(fn x -> Atom.to_string(x) end)
  end

end


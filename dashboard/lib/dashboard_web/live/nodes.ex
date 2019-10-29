defmodule DashboardWeb.NodesLive do
  use Phoenix.LiveView

  require Logger

  def render(assigns) do
    Phoenix.View.render(DashboardWeb.PageView, "nodes.html", assigns)
  end

  def mount(_, socket) do
    if connected?(socket) do
      Doorman.subscribe()
    end

    state = Doorman.nodes()
      |> Enum.map(fn x ->  {Atom.to_string(x), Dashboard.Node.new(x)} end)
      |> Map.new

    {:ok, assign(socket, :nodes, state)}
  end

  def handle_info({:node_added, node}, socket) do
    Logger.debug("node_added #{node}")
  end

  def handle_info({:node_removed, node}, socket) do
    Logger.debug("node_removed #{node}")
  end

  def handle_info(message, socket) do
    Logger.debug("unrecognized message #{message}")
    {:noreply, socket}
  end

  defp map_nodes(nodes) do
    nodes 
      |> Enum.map(fn x -> Atom.to_string(x) end)
  end

end


defmodule Dashboard.NodesLive do
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
    {:ok, assign(socket, :nodes, Doorman.nodes())}
  end

  def handle_info({:nodes_changed, nodes}, socket) do
    {:noreply, assign(socket, :nodes, nodes)}
  end

end
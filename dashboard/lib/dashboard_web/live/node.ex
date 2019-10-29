defmodule DashboardWeb.LiveView.Node do
  use Phoenix.LiveView
 
  def render(assigns) do
    Phoenix.View.render(DashboardWeb.PageView, "node.html", assigns)
  end

  def mount(%{node: node}, socket) do
    if connected?(socket) do
      Ears.subscribe()
    end

    updated = 
      socket
      |> assign(:vm, DashboardWeb.LiveView.Node.ViewModel.new(node))

    {:ok, updated}
  end

  def handle_info({:node_added, node}, socket) do

  end

end


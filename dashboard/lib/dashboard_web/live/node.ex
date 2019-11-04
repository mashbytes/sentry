defmodule DashboardWeb.LiveView.Node do
  use Phoenix.LiveView
 
  def render(assigns) do
    Phoenix.View.render(DashboardWeb.PageView, "node.html", assigns)
  end

  def mount(%{node: node}, socket) do
    if connected?(socket) do
      Ears.subscribe()
    end

    {:ok, assign(socket, :node, node)}
  end

  def handle_info(%Ears.Events.Noisy{ node: node }, socket) do
    case {node, socket.assigns.node} do
      {^node, ^node} ->
        {:noreply, assign(socket, :state, :noisy) }
      _ ->
        {:noreply, socket}
    end
  end

  def handle_info(%Ears.Events.Quiet{ node: node }, socket) do
    case {node, socket.assigns.node} do
      {^node, ^node} ->
        {:noreply, assign(socket, :state, :quiet) }
      _ ->
        {:noreply, socket}
    end
  end


end


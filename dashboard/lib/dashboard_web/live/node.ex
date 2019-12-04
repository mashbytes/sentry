defmodule DashboardWeb.NodeComponent do
  # use Phoenix.LiveComponent
  use Phoenix.LiveView

  # alias DashboardWeb.NodeView
  alias DashboardWeb.ViewModels.Node

  require Logger

  def render(assigns), do: Phoenix.View.render(DashboardWeb.PageView, "node.html", assigns)

  # def mount(%{node: node}, socket) do
  #   if connected?(socket) do
  #     Ears.subscribe()
  #   end

  #   {:ok, assign(socket, :node, node)}
  # end

  # def handle_info(%Ears.Events.Noisy{ node: node }, socket) do
  #   case {node, socket.assigns.node} do
  #     {^node, ^node} ->
  #       {:noreply, assign(socket, :state, :noisy) }
  #     _ ->
  #       {:noreply, socket}
  #   end
  # end

  # def handle_info(%Ears.Events.Quiet{ node: node }, socket) do
  #   case {node, socket.assigns.node} do
  #     {^node, ^node} ->
  #       {:noreply, assign(socket, :state, :quiet) }
  #     _ ->
  #       {:noreply, socket}
  #   end
  # end

  def handle_info(%Ears.Events.Noisy{} = event, socket) do
    key = Atom.to_string(event.node)
    socket =
      socket
      |> assign_new(key, fn -> Node.new(key) end)
      |> update(key, fn v -> Node.merge_sensor(v, "ears", event) end)

    Logger.debug("Noisy received")
    {:noreply, socket}
  end

  def handle_info(%Ears.Events.Quiet{} = event, socket) do
    key = Atom.to_string(event.node)
    socket =
      socket
      |> assign_new(key, fn -> Node.new(key) end)
      |> update(key, fn v -> Node.merge_sensor(v, "ears", event) end)


    Logger.debug("Quiet received")
    {:noreply, socket}
  end

  def handle_info(%Ears.Events.Offline{} = _event, socket) do
    Logger.debug("Offline received")
    {:noreply, socket}
  end

end


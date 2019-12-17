defmodule DashboardWeb.NodeComponent do
  use Phoenix.LiveView

  alias DashboardWeb.ViewModels.Node

  require Logger

  def render(assigns), do: Phoenix.View.render(DashboardWeb.PageView, "node.html", assigns)

  def mount(%{node: node}, socket) do
    Logger.debug("DashboardWeb.NodeComponent #{inspect node}")
    if connected?(socket) do
      {:ok, snapshot} = Ears.Nodes.snapshot_and_subscribe(node)
      Logger.debug("snapshot #{inspect snapshot}")
      socket =
        socket
        |> assign(:sound, snapshot)

      {:ok, assign(socket, :node, node)}
    else
      {:ok, assign(socket, :node, node)}
    end

  end

  def handle_info(%Ears.Events.Noisy{} = event, socket) do
    key = Atom.to_string(event.node)
    Logger.debug("#{inspect key}: Noisy received")
    {:noreply, assign(socket, :sound, event)}
  end

  def handle_info(%Ears.Events.Quiet{} = event, socket) do
    key = Atom.to_string(event.node)
    Logger.debug("#{inspect key}: Quiet received")
    {:noreply, assign(socket, :sound, event)}
  end

  def handle_info(%Ears.Events.Offline{} = event, socket) do
    key = Atom.to_string(event.node)
    Logger.debug("#{inspect key}: Offline received")
    {:noreply, assign(socket, :sound, event)}
  end

end


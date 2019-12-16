defmodule DashboardWeb.NodeComponent do
  use Phoenix.LiveComponent

  alias DashboardWeb.ViewModels.Node

  require Logger

  def render(assigns), do: Phoenix.View.render(DashboardWeb.PageView, "node.html", assigns)

  def mount(%{node: node}, socket) do
    if connected?(socket) do
      {:ok, snapshot} = Ears.Nodes.snapshot_and_subscribe(node)
      socket =
        socket
        |> assign("sounds", snapshot)

      {:ok, socket}
    else
      {:ok, socket}
    end

  end

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


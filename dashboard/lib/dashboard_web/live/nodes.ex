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

    socket =
      socket
      |> assign(:nodes, %{ :online => [], :offline => []})

    {:ok, socket}
  end

  def handle_info(%Doorman.Events.Nodes{online: online, offline: offline}, socket) do
    Logger.debug("nodes received online #{inspect online} offline #{inspect offline}")
    state = %{:online => online, :offline => offline}
    {:noreply, assign(socket, :nodes, state)}
  end

  def handle_info(%Doorman.Events.NodeUp{}, socket) do
    Logger.debug("NodeUp received")
    {:noreply, socket}
  end

  def handle_info(%Doorman.Events.NodeDown{}, socket) do
    Logger.debug("NodeUp received")
    {:noreply, socket}
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


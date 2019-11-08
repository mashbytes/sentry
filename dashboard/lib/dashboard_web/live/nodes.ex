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
      |> assign(:nodes, %{})

    {:ok, socket}
  end

  def handle_info(%Doorman.Events.Nodes{online: online, offline: offline}, socket) do
    Logger.debug("nodes received online #{inspect online} offline #{inspect offline}")
    online_map = online
      |> Map.new(fn n -> {n, DashboardWeb.NodesLive.Node.new(n)} end)
    
    nodes = socket.assigns.nodes
      |> Map.merge(online_map fn _k, existing, new) -> Map.merge(%{:status => :online} end)

    online_nodes = online
      |> Enum.map(fn on -> 
          Map.get(nodes, on, DashboardWeb.NodesLive.Node.new(on))
            |> Map.merge(%{:status => :online})
         end)
      |>

    nodes = Map.merge(nodes, online_nodes)

    {:noreply, assign(socket, :nodes, nodes)}
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

defmodule DashboardWeb.NodesLive.Node do
  defstruct [:name, :status, :sensors]

  def new(name, status \\ :offline, sensors \\ %{}) do
    %__MODULE__{ name: name, status: status, sensors: sensors }
  end
end
defmodule DashboardWeb.NodesLive do
  use Phoenix.LiveView

  require Logger

  alias DashboardWeb.NodesLive.Node
  # alias DashboardWeb.NodesLive.NodeState

  def render(assigns) do
    Phoenix.View.render(DashboardWeb.PageView, "nodes.html", assigns)
  end

  def mount(_, socket) do
    if connected?(socket) do
      Doorman.subscribe()
      Ears.subscribe()
    end

    socket =
      socket
      |> assign(:nodes, %{})

    {:ok, socket}
  end

  def handle_info(%Doorman.Events.Nodes{online: online, offline: offline}, socket) do
    Logger.debug("nodes received online #{inspect online} offline #{inspect offline}")
    nodes = socket.assigns.nodes
    online_map = online
      |> Map.new(fn n -> 
        state = Map.get(nodes, n, Node.new(n))
          |> Node.merge_status(:online)
        {n, state}
      end)
    
    nodes = nodes
      |> Map.merge(online_map)

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
    Logger.debug("unrecognized message #{inspect message}")
    {:noreply, socket}
  end

end

# defmodule DashboardWeb.NodesLive.Node do
#   defstruct [:name, :status]

#   def new(name, status \\ :offline) do
#     %__MODULE__{ name: name, status: status }
#   end
# end

# defmodule DashboardWeb.NodesLive.NodeState do
#   defstruct [:name, :sensors]

#   def new(name, sensors \\ %{}) do
#     %__MODULE__{ name: name, sensors: sensors }
#   end
# end


defmodule DashboardWeb.NodesLive.Node do
  defstruct [:name, :status, :sensors]

  def new(name, status \\ :offline, sensors \\ %{}) do
    %__MODULE__{ name: name, status: status, sensors: sensors }
  end

  def merge_status(%__MODULE__{status: status} = node, status) do
    node
  end

  def merge_status(%__MODULE__{} = node, new_status) do
    %{node | status: new_status}
  end

end
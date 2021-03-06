defmodule DashboardWeb.NodesLive do
  use Phoenix.LiveView

  require Logger

  alias DashboardWeb.ViewModels.Node

  def render(assigns) do
    Phoenix.View.render(DashboardWeb.PageView, "nodes.html", assigns)
  end

  def mount(_, socket) do

    if connected?(socket) do
      Doorman.subscribe()
    end

    socket =
      socket
      |> assign_new(:online, fn -> [] end)
      |> assign_new(:offline, fn -> [] end)

    # Logger.debug("mount: assigns #{inspect socket.assigns}")

    {:ok, socket}
  end

  def handle_info(%Doorman.Events.Nodes{online: online, offline: offline}, socket) do
    Logger.debug("nodes received online #{inspect online} offline #{inspect offline}")
    # todo remove entries into assigns for nodes that no longer exist

    socket =
      socket
      |> assign(:online, online)
      |> assign(:offline, offline)

    # Logger.debug("handle_info socket.assigns #{inspect socket.assigns}")

    {:noreply, socket}
  end

  def handle_info(%Doorman.Events.NodeUp{} = event, socket) do
    Logger.debug("NodeUp received")
    online =
      socket.assigns.online
      |> MapSet.new
      |> MapSet.put(event.node)
      |> MapSet.to_list

    {:noreply, assign(socket, :online, online)}
  end

  def handle_info(%Doorman.Events.NodeDown{} = event, socket) do
    Logger.debug("NodeDown received")
    offline =
      socket.assigns.offline
      |> MapSet.new
      |> MapSet.put(event.node)
      |> MapSet.to_list

    {:noreply, assign(socket, :offline, offline)}
  end

end

defmodule DashboardWeb.ViewModels.Node do
  defstruct [:name, :sensors]

  def new(name, sensors \\ %{}) do
    %__MODULE__{ name: name, sensors: sensors }
  end

  def merge_sensor(%__MODULE__{} = node, key, state) do
    sensors =
      node.sensors
      |> Map.put(key, state)
    %{node | sensors: sensors}
  end

end

defimpl Phoenix.HTML.Safe, for: DashboardWeb.ViewModels.Node do
  def to_iodata(data), do: inspect(data)
end

defimpl Phoenix.HTML.Safe, for: Ears.Events.Noisy do
  def to_iodata(data), do: inspect(data)
end

defimpl Phoenix.HTML.Safe, for: Ears.Events.Quiet do
  def to_iodata(data), do: inspect(data)
end

defimpl Phoenix.HTML.Safe, for: Ears.Events.Offline do
  def to_iodata(data), do: inspect(data)
end

defmodule DashboardWeb.NodesLive do
  use Phoenix.LiveView

  require Logger

  alias DashboardWeb.NodesLive.Node

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
      |> assign(:online, [])
      |> assign(:offline, [])

    {:ok, socket}
  end

  def handle_info(%Doorman.Events.Nodes{online: online, offline: offline}, socket) do
    Logger.debug("nodes received online #{inspect online} offline #{inspect offline}")
    # todo remove entries into assigns for nodes that no longer exist

    socket =
      socket
      |> assign(:online, Enum.map(online, fn x -> Atom.to_string(x) end))
      |> assign(:offline, Enum.map(offline, fn x -> Atom.to_string(x) end))

    {:noreply, socket}
  end

  def handle_info(%Doorman.Events.NodeUp{} = event, socket) do
    Logger.debug("NodeUp received")
    online =
      socket.assigns.online
      |> MapSet.new
      |> MapSet.put(Atom.to_string(event.node))
      |> MapSet.to_list

    {:noreply, assign(socket, :online, online)}
  end

  def handle_info(%Doorman.Events.NodeDown{} = event, socket) do
    Logger.debug("NodeDown received")
    offline =
      socket.assigns.offline
      |> MapSet.new
      |> MapSet.put(Atom.to_string(event.node))
      |> MapSet.to_list

    {:noreply, assign(socket, :offline, offline)}
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


  def handle_info(message, socket) do
    Logger.debug("unrecognized message #{inspect message}")
    {:noreply, socket}
  end

end

defmodule DashboardWeb.NodesLive.Node do
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

defimpl Phoenix.HTML.Safe, for: DashboardWeb.NodesLive.Node do
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

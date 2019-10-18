defmodule Doorman.Server do

  use GenServer

  alias Phoenix.PubSub

  def start_link(topic, otp_opts \\ []) when is_binary(topic) do
    GenServer.start_link(__MODULE__, topic, otp_opts)
  end

  def nodes
    GenServer.call(__MODULE__, :nodes)
  end

  defp broadcast(topic, message) do
    PubSub.broadcast(:nodes, topic, {:pubsub_spike, message})
  end

  def subscribe do
    PubSub.subscribe(:nodes, @topic)
  end

  def init(topic) do
    :net_kernel.monitor_nodes(true)
    {:ok, []}
  end

  def handle_info({:nodeup, name}, state) do
    {:noreply, [name | nodes]}
  end

  def handle_info({:nodedown, name}, nodes) do
    {:noreply, [name | nodes]}
  end

  def handle_call(:nodes, _from, nodes) do
    {:reply, nodes}
  end

end

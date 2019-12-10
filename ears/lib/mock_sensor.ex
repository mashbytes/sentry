defmodule Ears.MockSensor do

  use GenServer

  require Logger

  @pin 5
  @high_signal 1
  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(@name, nil, name: @name)
  end

  def init(_) do
    {:ok, pid} = Circuits.GPIO.open(@pin, :output)
    schedule_signal()
    {:ok, pid}
  end

  defp schedule_signal() do
    time = :rand.uniform(10)
    Logger.debug("Scheduling tick for #{time}s")
    Process.send_after(self(), :tick, time * 1000)
  end

  def handle_info(:tick, pid) do
    Logger.debug("Writing signal #{@high_signal} to #{inspect pid}")
    :ok = Circuits.GPIO.write(pid, @high_signal)
    :ok = Circuits.GPIO.write(pid, 0)
    schedule_signal()
    {:noreply, pid}
  end

end

defmodule Ears.Sensor do

  use GenServer

  require Logger

  alias Ears.PubSub
  alias Ears.Sensor.Model

  @input_pin Application.get_env(:ears, :sound_input_pin, 4)
  @tick_timeout Application.get_env(:ears, :tick_timeout, 5_000)
  @setup_timeout Application.get_env(:ears, :setup_timeout, 10_000)
  @high_signal 1
  @name __MODULE__


  def start_link(state) do
    GenServer.start_link(@name, state, name: @name)
  end

  def init(_) do
    Logger.debug("Starting hardware on pin #{@input_pin}")
    {:ok, Model.new(), 0}
  end

  def broadcast_snapshot() do
    GenServer.cast(@name, :snapshot)
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, @high_signal}, %Model{state: :offline} = existing) do
    updated = Model.merge_state(existing, :noisy, convert_timestamp_to_utc(timestamp))
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    broadcast(updated)
    {:noreply, updated, @tick_timeout}
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, @high_signal}, %Model{state: :quiet} = existing) do
    updated = Model.merge_state(existing, :noisy, convert_timestamp_to_utc(timestamp))
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    broadcast(updated)
    {:noreply, updated, @tick_timeout}
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, @high_signal}, %Model{state: :noisy} = existing) do
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect existing}")
    {:noreply, existing, @tick_timeout}
  end

  def handle_info(:timeout, %Model{state: :offline} = existing) do
    updated = setup_gpio(existing)
    Logger.debug("Setting up #{@name}, model is #{inspect updated}")
    broadcast(updated)
    {:noreply, updated, @setup_timeout}
  end

  def handle_info(:timeout, %Model{state: :noisy} = existing) do
    updated = Model.merge_state(existing, :quiet, DateTime.utc_now())
    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect updated}]")
    broadcast(updated)
    {:noreply, updated}
  end

  def handle_info(:timeout, %Model{state: :quiet} = existing) do
    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect existing}]")
    {:noreply, existing}
  end

  def handle_cast(:snapshot, model) do
    broadcast(model)
    {:noreply, model}
  end

  def broadcast(%Model{} = model) do
    PubSub.broadcast(model.state, model.since)
  end

  defp convert_timestamp_to_utc(timestamp) do
    {system_uptime, _} = :erlang.statistics(:wall_clock)
    DateTime.utc_now()
      |> DateTime.add(-system_uptime, :millisecond)
      |> DateTime.add(timestamp, :nanosecond)
  end

  defp setup_gpio(%Model{state: :offline} = existing) do
    case Circuits.GPIO.open(@input_pin, :input) do
      {:ok, pid} ->
        :ok = Circuits.GPIO.set_interrupts(pid, :rising)
        Model.merge_gpio(existing, pid)
      _ ->
        Model.merge_gpio(existing, nil)
    end
  end

end


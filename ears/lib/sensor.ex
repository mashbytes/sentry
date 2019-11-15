defmodule Ears.Sensor do

  use GenServer

  require Logger

  alias Ears.PubSub
  alias Ears.Sensor.Model

  @input_pin Application.get_env(:ears, :sound_input_pin, 4)
  @tick_timeout Application.get_env(:ears, :tick_timeout, 2_000)
  @setup_timeout Application.get_env(:ears, :setup_timeout, 10_000)
  @name __MODULE__


  def start_link(state) do
    GenServer.start_link(@name, state, name: @name)
  end

  def init(_) do
    Logger.debug("Starting hardware on pin #{@input_pin}")
    GenServer.cast(@name, :setup)
    model = Model.new()
    broadcast(model)
    {:ok, model}
  end

  def broadcast_snapshot() do
    GenServer.cast(@name, :snapshot)
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, 1}, %Model{state: :offline} = existing) do
    updated = Model.merge_state(existing, :noisy, timestamp)
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    broadcast(updated)
    {:noreply, updated, @tick_timeout}
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, 1}, %Model{state: :quiet} = existing) do
    updated = Model.merge_state(existing, :noisy, timestamp)
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    broadcast(updated)
    {:noreply, updated, @tick_timeout}
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, 1}, %Model{state: :noisy} = existing) do
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect existing}")
    {:noreply, existing, @tick_timeout}
  end

  def handle_info(:timeout, %Model{state: :offline} = existing) do
    updated = Model.merge_gpio(existing, nil)
    Logger.debug("Timeout occurred waiting for gpio setup, model is [#{inspect updated}]")
    broadcast(updated)
    GenServer.cast(@name, :setup)
    {:noreply, updated}
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

  def handle_info(:timeout, existing) do
    updated = Model.merge_state(existing, :quiet, DateTime.utc_now())
    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect updated}]")
    if existing != updated do
      broadcast(updated)
    end

    {:noreply, updated}
  end

  def handle_cast(:snapshot, model) do
    broadcast(model)
    {:noreply, model}
  end

  def handle_cast(:setup, %Model{state: :offline} = model) do
    Logger.debug("Setting up #{@name}")

    case Circuits.GPIO.open(@input_pin, :input) do
      {:ok, pid} ->
        :ok = Circuits.GPIO.set_interrupts(pid, :rising)
        {:noreply, Model.merge_gpio(model, pid), @setup_timeout}
      _ ->
        {:noreply, model, @setup_timeout}
    end
  end

  def broadcast(%Model{} = model) do
    PubSub.broadcast(model.state, model.since)
  end
end


defmodule Ears.Sensor do
    
  use GenServer

  require Logger

  alias Ears.State
  alias Ears.Events
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
    PubSub.broadcast(Events.Offline.new())
    {:ok, Model.new()}
  end

  def broadcast_snapshot() do
    GenServer.call(@name, :snapshot)
  end

  def handle_cast(:setup, %Model{state: %Ears.State.Offline{}} = model) do
    Logger.debug("Setting up #{@name}")
        
    case Circuits.GPIO.open(@input_pin, :input) do
      {:ok, pid} -> 
        :ok = Circuits.GPIO.set_interrupts(pid, :rising)
        {:noreply, Model.merge_gpio(model, pid), @setup_timeout}
      _ ->
        {:noreply, model, @setup_timeout}
    end
  end

  def handle_info(:timeout, %Model{state: %Ears.State.Offline{}} = model) do
    updated = Model.merge_gpio(model, nil)
    PubSub.broadcast(updated.state)

    GenServer.cast(@name, :setup)

    Logger.debug("Timeout occurred waiting for gpio setup, model is [#{inspect updated}]")
    {:noreply, updated}    
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, 1}, model) do
    updated = Model.merge_state(model, State.Noisy.new(timestamp))
    PubSub.broadcast(updated.state)

    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    {:noreply, updated, @tick_timeout}
  end

  def handle_info(:timeout, model) do
    updated = Model.merge_state(model, State.Quiet.new())

    PubSub.broadcast(updated.state)

    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect updated}]")
    {:noreply, updated}    
  end

  def handle_call(:snapshot, model) do
    PubSub.broadcast(model.state)
    {:noreply, model}
  end

end


defmodule Ears.Sensor do
    
  use GenServer

  require Logger

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
    model = update_model(%{gpio: nil, state: nil}, Ears.State.new(Node.self(), :offline, DateTime.utc_now()))
    {:ok, model}
  end

  def handle_cast(:setup, %{state: %Ears.State{status: :offline}} = model) do
    Logger.debug("Setting up #{@name}")
    case Circuits.GPIO.open(@input_pin, :input) do
      {:ok, pid} -> 
        :ok = Circuits.GPIO.set_interrupts(pid, :rising)
        {:noreply, model, @setup_timeout}
      _ ->
        {:noreply, model, @setup_timeout}
    end
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, 1}, model) do
    new_model = update_model(model, Ears.State.new(Node.self(), :up, timestamp))

    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect new_model}")
    {:noreply, new_model, @tick_timeout}
  end

  def handle_info(:timeout, %{state: %Ears.State{status: :offline}} = model) do
    new_model = %{model | gpio: nil}
    
    GenServer.cast(@name, :setup)

    Logger.debug("Timeout occurred waiting for gpio setup, model is [#{inspect new_model}]")
    {:noreply, new_model}    
  end

  def handle_info(:timeout, model) do
    new_model = update_model(model, Ears.State.new(:down, DateTime.utc_now()))

    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect new_model}]")
    {:noreply, new_model}    
  end

  def handle_call(:snapshot, _, %{state: state} = model) do
    Logger.debug("Fetching snapshot [#{inspect state}]")
    {:reply, state, model}
  end

  defp update_model(%{state: nil} = model, new_state) do
    Logger.debug("State changed, publishing")
    Ears.PubSub.broadcast(new_state)
    %{model | state: new_state}
  end

  defp update_model(%{state: old_state} = model, new_state) do
    merged_state = Ears.State.merge(old_state, new_state)
    case merged_state do
      ^old_state -> 
        Logger.debug("State not changed, not publishing")
      _ ->
        Logger.debug("State changed, publishing")
        Ears.PubSub.broadcast(merged_state)
    end
    %{model | state: merged_state}
  end

  def snapshot() do
    GenServer.call(@name, :snapshot)
  end

end

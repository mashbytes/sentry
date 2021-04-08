defmodule Sentry.Sound.Sensor do

  use GenServer

  require Logger

  alias Sentry.Sound.Sensor.State
  alias Sentry.Sound.Sensor.Reading

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
    {:ok, State.new(), 0}
  end

  def handle_info({:circuits_gpio, @input_pin, timestamp, @high_signal}, %State{} = existing) do
    reading = Reading.new(:high, convert_timestamp_to_utc(timestamp))
    updated = State.merge_reading(existing, reading)
    Logger.debug("Received high signal @#{timestamp}, model is [#{inspect updated}")
    {:noreply, updated, @tick_timeout}
  end

  def handle_info(:timeout, %State{ gpio: nil } = existing) do
    updated = setup_gpio(existing)
    Logger.debug("Setting up #{@name}, model is #{inspect updated}")
    {:noreply, updated, @setup_timeout}
  end

  def handle_info(:timeout, %State{} = existing) do
    reading = Reading.new(:low)
    updated = State.merge_reading(existing, reading)
    Logger.debug("Timeout occurred waiting for signal, model is [#{inspect updated}]")
    {:noreply, updated}
  end

  defp convert_timestamp_to_utc(timestamp) do
    {system_uptime, _} = :erlang.statistics(:wall_clock)
    DateTime.utc_now()
      |> DateTime.add(-system_uptime, :millisecond)
      |> DateTime.add(timestamp, :nanosecond)
  end

  defp setup_gpio(%State{ gpio: nil } = existing) do
    case Circuits.GPIO.open(@input_pin, :input) do
      {:ok, pid} ->
        :ok = Circuits.GPIO.set_interrupts(pid, :rising)
        State.merge_gpio(existing, pid)
      _ ->
        State.merge_gpio(existing, nil)
    end
  end

end


defmodule Sentry.Sound.Sensor.State do

  alias Sentry.Sound.Sensor.Reading

  defstruct [:gpio, :readings]

  def new(gpio \\ nil, readings \\ []) do
    %__MODULE__{ gpio: gpio, readings: readings}
  end

  def merge_gpio(%__MODULE__{} = state, gpio) do
    %{state | gpio: gpio}
  end

  def merge_reading(%__MODULE__{ readings: [] } = state, reading) do
    %{state | readings: [reading]}
  end

  def merge_reading(%__MODULE__{ readings: readings } = state, reading) do
    [head|tail] = readings
    case has_reading_position_changed(head, reading) do
      true ->
        %{state | readings: [reading | readings]}
      _ -> state
    end
  end

  def readings_within_interval(%__MODULE__{ readings: readings }, interval) do
    readings_since_date(readings, Date.utc_now)
  end


  defp readings_since_date([], _date) do
    []
  end

  defp readings_since_date([h|[]], _date) do
    [h]
  end

  defp readings_since_date([h|t], date) when h.since < date do
    [h|readings_since_date(t, date)]
  end

  defp has_reading_position_changed(%Reading{position: position}, %Reading{position: position}) do
    false
  end

  defp has_reading_position_changed(%Reading{}, %Reading{}) do
    true
  end

end

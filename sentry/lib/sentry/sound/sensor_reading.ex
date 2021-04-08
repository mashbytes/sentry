defmodule Sentry.Sound.Sensor.Reading do
  defstruct [:position, :since]

  def new(position \\ :low, since \\ DateTime.utc_now()) do
    %__MODULE__{position: position, since: since}
  end

end

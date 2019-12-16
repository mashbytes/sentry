defmodule Ears.Sensor.Model do
    defstruct [:gpio, :state, :since]

    def new(gpio \\ nil, state \\ :offline, since \\ DateTime.utc_now()) do
      %__MODULE__{ gpio: gpio, state: state, since: since}
    end

    def merge_state(%__MODULE__{state: state} = model, state, _) do
      model
    end

    def merge_state(%__MODULE__{} = model, state, timestamp) do
      %{model | state: state, since: timestamp}
    end

    def merge_gpio(%__MODULE__{} = model, gpio) do
      %{model | gpio: gpio}
    end

end


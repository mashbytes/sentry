defmodule Ears.Sensor.Model do
    defstruct [:gpio, :state]

    def new(gpio \\ nil, state \\ Ears.State.Offline.new()) do
      %__MODULE__{ gpio: gpio, state: state}
    end

    def merge_state(%__MODULE__{state: state} = model, state) do
      model
    end

    def merge_state(%__MODULE__{} = model, state) do
      %{model | state: state}
    end

    def merge_gpio(%__MODULE__{} = model, gpio) do
      %{model | gpio: gpio}
    end

end


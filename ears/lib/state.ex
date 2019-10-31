defmodule Ears.State do
  
  defmacro __using__(_) do
    quote do
      defstruct [:since]

      def new(since \\ DateTime.utc_now()) do
        %__MODULE__{ since: since }
      end
    end
  end

end

defmodule Ears.State.Offline do
  use Ears.State
end

defmodule Ears.State.Noisy do
  use Ears.State
end

defmodule Ears.State.Quiet do
  use Ears.State
end


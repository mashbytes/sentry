defmodule Ears.Event do

  defmacro __using__(_) do
    quote do
      defstruct [:node, :since]

      def new(since \\ DateTime.utc_now(), node \\ Node.self()) do
        %__MODULE__{ node: node, since: since }
      end
    end
  end

end

defmodule Ears.Events.Noisy do
  use Ears.Event
end

defmodule Ears.Events.Quiet do
  use Ears.Event
end

defmodule Ears.Events.Offline do
  use Ears.Event
end


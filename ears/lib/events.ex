defmodule Ears.Event do
  
  defmacro __using__(_) do
    quote do
      defstruct [:host, :since]

      def new(since \\ DateTime.utc_now(), host \\ Node.self()) do
        %__MODULE__{ host: host, since: since }
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


defmodule Ears.State do

  @enforce_keys [:status, :since]
  defstruct [:status, :since]

  @type status :: :up | :down | :offline | :waiting

  @type t() :: %__MODULE__{
        status: status,
        since: DateTime.t()
      }

  @spec new(status, DateTime.t) :: Ears.State.t
  def new(status, since) do
    %Ears.State{status: status, since: since}
  end

  def merge(nil, %Ears.State{} = stateB) do
    stateB
  end

  def merge(%Ears.State{status: statusA, since: _} = stateA, %Ears.State{status: statusB, since: _} = stateB) do
    case {statusA, statusB} do
      {statusA, statusA} -> stateA
      _ -> stateB
    end
  end

end
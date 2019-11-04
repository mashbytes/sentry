defmodule Dashboard.Node do
  require Logger

  @enforce_keys [:name, :status, :components]
  defstruct [:name, :status, :components] 

  @type status :: :online | :offline

  @type t() :: %__MODULE__{
        name: Atom.t(),
        status: status,
        components: Map.t()
      }

  # @spec new(name) :: Dashboard.Node.t
  def new(name) do
    %Dashboard.Node{name: name, status: :online, components: %{}}
  end

  # def merge(%Dashboard.Node{} = node, %Ears.State{} = state) do
  #   updated_components = Map.put(node.components, "ears", state)
  #   %{node | components: updated_components}
  # end

  # def merge(%Dashboard.Node{} = node, state) do
  #   Logger.warn("Unsupported update #{inspect state}")
  #   node
  # end

end
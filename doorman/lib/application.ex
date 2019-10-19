defmodule Doorman.Application do
  use Application

  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    topologies = [
      doorman: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      # supervisor(Phoenix.PubSub.PG2, [@name, []]),
      # supervisor(Registry, [:duplicate, :pubsub_elixir_registry]),
      {Cluster.Supervisor, [topologies, [name: Doorman.ClusterSupervisor]]},
      Doorman.Server
      # worker(Doorman.Server, @name)
    ]

    opts = [strategy: :one_for_one, name: Doorman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

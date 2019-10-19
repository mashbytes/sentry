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
      {Phoenix.PubSub.PG2, name: Doorman.PubSub},
      {Cluster.Supervisor, [topologies, [name: Doorman.ClusterSupervisor]]},
      Doorman.Server
    ]

    opts = [strategy: :one_for_one, name: Doorman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

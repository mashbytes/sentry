defmodule Eyes.Application do
  @moduledoc false

  use Application


  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    camera = Application.get_env(:picam, :camera, Picam.Camera)
    port = Application.get_env(:picam, :http_port, 4001)

    IO.puts("Camera #{camera}")

    children = [
      worker(camera, []),
      {Plug.Cowboy, scheme: :http, plug: Eyes.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: Eyes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

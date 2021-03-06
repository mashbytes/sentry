# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :firmware, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

config :dashboard, DashboardWeb.Endpoint,
  url: [host: "nerves.local"],
  http: [port: 80],
  secret_key_base: "ngkJ+MOUsr+mcdcWmiHkyy8L/HqT892cEtLzTKlOyQwxIpWwy6qRa3H5wtZUP2yD",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [view: DashboardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Nerves.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "SWjnR7UyD/k1ns5TvlpM5aWtp0emA+Mm"
  ],
  code_reloader: false


config :phoenix, :json_library, Jason


if Mix.target() != :host do
  import_config "target.exs"
end

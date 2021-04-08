# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :sentry, SentryWeb.Endpoint,
  url: [host: "nerves.local"],
  http: [port: 80],
  server: true,
  secret_key_base: "LVnHsreX93DzEVVC+rKQLT6CX6qmjjZgEiIQ9a5QXHooTWKdDGhlIFDdHblMP60/",
  render_errors: [view: SentryWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Sentry.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
env_config = "#{Mix.env()}.exs"
IO.puts("Importing config from #{env_config}")
import_config env_config


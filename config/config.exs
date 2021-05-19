# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :discordia, DiscordiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WjElwg6/wi8RCPy5RL9MiC86a9JfnXLPYy2I0SPOVlRJGsHCGYd8/iZDzeTZEazN",
  render_errors: [view: DiscordiaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Discordia.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "Gx3Q5BUd0jFZ8bFDK+bzoRkpaU1chvFh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

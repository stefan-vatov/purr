# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :purr, PurrWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fKur7CMR5I0S/0IKe/Pn/mM5yCf+55+VdMAwB/l+z0g4zL5VPfkmEt2P6/b+J17y",
  render_errors: [view: PurrWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Purr.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
import_config "purr.exs"

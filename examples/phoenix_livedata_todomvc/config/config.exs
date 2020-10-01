# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phoenix_livedata_todomvc,
  ecto_repos: [PhoenixLivedataTodomvc.Repo]

# Configures the endpoint
config :phoenix_livedata_todomvc, PhoenixLivedataTodomvcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EPfvPGKjgr6LmVfbDz10B9csk695LUhh6Uc0iNn07QlI6bt5giRaVE4AIZyOA/Qy",
  render_errors: [view: PhoenixLivedataTodomvcWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixLivedataTodomvc.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "O6mBmZ6W"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

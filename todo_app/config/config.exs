use Mix.Config

config :todo, http_port: 5454

# looks for .\dev.exs .\test.exs or .\prod.exs
# to setup additional mix environment specific
# config settings
import_config "#{Mix.env()}.exs"
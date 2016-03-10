use Mix.Config

config :trot,
  port: 4000,
  router: Shaker.Router

config :shaker, :saltapi,
  url: System.get_env("SALTAPI_URL") || "http://localhost:8000",
  username: System.get_env("SALTAPI_USER") || nil,
  password: System.get_env("SALTAPI_PASS") || nil,
  timeout: 300_000

config :logger, :console, metadata: [:request_id]
config :logger,
  level: :debug,
  backends: [:console, {LoggerFileBackend, :debug_log}]
config :logger, :debug_log,
  path: "/var/log/shaker/debug.log",
  level: :debug,
  metadata: [:request_id]

use Mix.Config

config :trot,
  port: 4000,
  router: Shaker.Router

config :shaker, :saltapi,
  url: System.get_env("SALTAPI_URL") || "http://localhost:8000",
  username: System.get_env("SALTAPI_USER") || nil,
  password: System.get_env("SALTAPI_PASS") || nil


config :logger, level: :debug

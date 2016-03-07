defmodule Shaker.Mixfile do
  use Mix.Project

  def project do
    [app: :shaker,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger_file_backend, :logger, :trot, :httpotion, :poison, :conform]]
  end

  defp deps do
    [
      {:trot, github: "hexedpackets/trot"},
      {:httpotion, "~> 2.2.0"},
      {:poison, "~> 2.0", override: true},
      {:shouldi, "~> 0.3.0", only: :test},
      {:exrm, "~> 1.0", override: true},
      {:conform, "~> 2.0", override: true},
      {:conform_exrm, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.6"},
    ]
  end
end

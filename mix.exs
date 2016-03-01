defmodule Shaker.Mixfile do
  use Mix.Project

  def project do
    [app: :shaker,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :trot, :httpotion]]
  end

  defp deps do
    [
      {:trot, github: "hexedpackets/trot"},
      {:httpotion, "~> 2.2.0"},
      {:poison, "~> 2.0", override: true},
    ]
  end
end

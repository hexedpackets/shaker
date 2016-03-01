# Shaker

Gateway that sits in front of the SaltStack netapi's to make them more RESTful.

Responses are parsed and turned into meaninful status codes.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add shaker to your list of dependencies in `mix.exs`:

        def deps do
          [{:shaker, "~> 0.0.1"}]
        end

  2. Ensure shaker is started before your application:

        def application do
          [applications: [:shaker]]
        end

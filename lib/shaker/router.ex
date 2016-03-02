defmodule Shaker.Router do
  use Plug.Builder
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     json_decoder: Poison

  require Logger
  get "/", do: Shaker.salt_call("/")

  post "/:tgt/:fun" do
    {user, pass} = conn.req_headers |> Enum.into(%{}) |> Shaker.auth_info(conn.params)
    Shaker.salt_call(:post, "/run", [tgt: tgt, fun: fun, username: user, password: pass, arg: parse_args(conn)])
  end

  import_routes Trot.NotFound

  defp parse_args(conn) do
    # Treat body/query args with no values as being args for the salt function
    arg = conn.query_string
    |> URI.decode
    |> String.split("&")
    |> Enum.filter(fn(q) -> not String.contains?(q, "=") end)
    |> Enum.filter(&(String.length(&1) > 0))
  end
end

defmodule Shaker.Router do
  use Plug.Builder
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison
  use Trot.Router

  require Logger

  get "/", do: Shaker.salt_call("/")

  post "/:tgt/:fun" do
    {user, pass} = conn.req_headers |> Enum.into(%{}) |> Shaker.auth_info(conn.params)
    {arg, kwarg} = parse_query(conn)
    kwarg = kwarg |> Dict.merge(conn.params) |> Dict.delete("username") |> Dict.delete("password")

    Shaker.salt_call(:post, "/run", [tgt: tgt, fun: fun, username: user, password: pass, arg: arg, kwarg: kwarg])
  end

  import_routes Trot.NotFound

  defp parse_query(conn) do
    # Treat body/query args with no values as being args for the salt function
    query = conn.query_string
    |> URI.decode_query
    |> Enum.group_by(fn({_arg, value}) -> is_nil(value) end)

    args = Dict.get(query, true, []) |> Enum.map(fn({k, _}) -> k end)
    kwargs = Dict.get(query, false, %{}) |> Enum.into(%{})

    {args, kwargs}
  end
end

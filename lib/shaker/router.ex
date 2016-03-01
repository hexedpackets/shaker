defmodule Shaker.Router do
  use Plug.Builder
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded]
  use Trot.Router

  get "/", do: Shaker.salt_call("/")

  post "/:tgt/:fun/run" do
    {user, pass} = conn.request_headers |> Enum.into(%{}) |> Shaker.auth_info(conn.body)
    Shaker.salt_call(:post, "/run", [tgt: tgt, fun: fun, username: user, password: pass])
  end

  import_routes Trot.NotFound
end

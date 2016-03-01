defmodule Shaker.Router do
  use Trot.Router
  require Logger

  get "/" do
    Shaker.salt_call("/")
  end

  post "/:tgt/:fun/run" do
    resp = Shaker.salt_call(:post, "/run", [tgt: tgt, fun: fun])
    Logger.debug "Responding with: #{inspect resp}"
    resp
  end

  import_routes Trot.NotFound
end

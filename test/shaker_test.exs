defmodule ShakerTest do
  use ShouldI
  alias HTTPotion.Response
  import Plug.Conn.Status

  defp response(body \\ "foobar"), do: %Response{status_code: 200, body: body}

  should "pass status code on non-200 responses" do
    assert %Response{status_code: 420, body: "foobar"} |> Shaker.parse_salt_resp == 420
  end

  should "return an error code for non-json body" do
    {ret_code, _body} = response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  should "return an error code for an empty return" do
    {ret_code, _body} = %{return: []} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  should "pass through a string return" do
    {ret_code, body} = %{return: "explosions!"} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) == 200
    assert body == "explosions!"
  end

  having "a username and password" do
    setup_all context do
      context = context
      |> Dict.put(:user, "legitadmin")
      |> Dict.put(:password, "letmein")
      {:ok, context}
    end

    should "pull username and password from the body params for form auth", context do
      auth = Shaker.auth_info(%{"x-auth-type" => "form"}, %{"username" => context[:user], "password" => context[:password]})
      assert auth == {context[:user], context[:password]}
    end

    should "use form auth by default", context do
      assert Shaker.auth_info(%{}, %{"username" => context[:user], "password" => context[:password]}) == {context[:user], context[:password]}
    end
  end

  should "validate boolean returns" do
    {ret_code, _body} = %{return: [%{"node" => true}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) == 200

    {ret_code, _body} = %{return: [%{"node" => false}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 500
  end

  should "validate state returns" do
    {ret_code, _body} = %{return: [%{"node" => %{"some crazy state" => %{"result" => true}}}]}
    |> Poison.encode!
    |> response
    |> Shaker.parse_salt_resp
    assert code(ret_code) == 200

    {ret_code, _body} = %{return: [%{"node" => %{"some crazy state" => %{"result" => true}, "a broken state" => %{"result" => false}}}]}
    |> Poison.encode!
    |> response
    |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  should "mark string results as errors" do
    {ret_code, _body} = %{return: [%{"node" => "look at my error"}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  should "validate list returns" do
    {ret_code, _body} = %{return: [%{"node" => [true]}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) == 200

    {ret_code, _body} = %{return: [%{"node" => [true, "look at my error"]}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  should "validate cmdmod results" do
    {ret_code, _body} = %{return: [%{"node" => %{pid: 1234, retcode: 0, stderr: "", stdout: ""}}]}
    |> Poison.encode!
    |> response
    |> Shaker.parse_salt_resp
    assert code(ret_code) == 200

    {ret_code, _body} = %{return: [%{"node" => %{pid: 1234, retcode: 1, stderr: "", stdout: ""}}]}
    |> Poison.encode!
    |> response
    |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  having "a stupid long salt command" do
    setup_all context do
      long_id = "cmd_|-super long command_|-ls -tr /var/cache/salt/minion/extrn_files/base/awesome-build-bucket-in-region-us-east-5/website/master/integrated/experimental/tested/ | head -n 2 | xargs -n1 -I{} rm -rf /var/cache/salt/minion/extrn_files/base/awesome-build-bucket-in-region-us-east-5/website/master/integrated/experimental/tested/{}_|-run"
      context = context
      |> Dict.put(:long_id, long_id)
      {:ok, context}
    end

    should "parse a long lowstate id", context do
      {ret_code, _body} = %{return: [%{"node" => %{context[:long_id] => %{result: true}}}]}
      |> Poison.encode!
      |> response
      |> Shaker.parse_salt_resp
      assert code(ret_code) == 200
    end
  end
end

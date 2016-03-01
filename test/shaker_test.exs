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

    should "parse url-encoded body auth", context do
      auth = Shaker.auth_info(%{"x-auth-type" => "form"}, "username=#{context[:user]}&password=#{context[:password]}")
      assert auth == {context[:user], context[:password]}
    end

    should "use url-encoded body auth when nothing else is specified", context do
      assert Shaker.auth_info(%{}, "username=#{context[:user]}&password=#{context[:password]}") == {context[:user], context[:password]}
    end
  end

  should "validate boolean returns" do
    {ret_code, body} = %{return: [%{"node" => true}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) == 200

    {ret_code, body} = %{return: [%{"node" => false}]} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 500
  end
end

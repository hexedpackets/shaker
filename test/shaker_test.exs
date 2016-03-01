defmodule ShakerTest do
  use ExUnit.Case
  alias HTTPotion.Response
  import Plug.Conn.Status

  defp response(body \\ ""), do: %Response{status_code: 200, body: body}

  test "non-200 responses pass their status code through" do
    assert %Response{status_code: 420, body: "foobar"} |> Shaker.parse_salt_resp == 420
  end

  test "non-json body causes an error" do
    {ret_code, _body} = response("foobar") |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  test "empty return throws an error" do
    {ret_code, _body} = %{return: []} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) >= 400
  end

  test "string return gets passed through" do
    {ret_code, body} = %{return: "explosions!"} |> Poison.encode! |> response |> Shaker.parse_salt_resp
    assert code(ret_code) == 200
    assert body == "explosions!"
  end
end

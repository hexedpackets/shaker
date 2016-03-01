defmodule Shaker do
  require Logger

  defp default_settings do
    settings = Application.get_env(:shaker, :saltapi)
    [
      client: "local",
      eauth: "pam",
      username: settings[:username],
      password: settings[:password],
    ]
  end


  def salt_call(path), do: salt_call(:get, path)
  def salt_call(method, path, body \\ "", headers \\ [])
  def salt_call(method, path, body, headers) when is_binary(body) do
    settings = Application.get_env(:shaker, :saltapi)
    url = settings[:url] |> Path.join(path)

    Logger.debug "Sending #{inspect body} to #{url} with headers #{inspect headers}"

    resp = HTTPotion.request(method, url, [body: body, headers: headers, timeout: 300_000])

    Logger.debug "SaltAPI response for #{path}: #{inspect resp}"
    resp |> parse_salt_resp
  end
  def salt_call(method, path, body, headers) do
    body = body
    |> Enum.into([])
    |> Keyword.merge(default_settings)
    |> URI.encode_query

    headers = headers
    |> Enum.into([])
    |> Keyword.put(:"Content-Type", "application/x-www-form-urlencoded")
    salt_call(method, path, body, headers)
  end

  def parse_salt_resp(%HTTPotion.Response{status_code: 200, body: body}) do
    body |> Poison.decode(keys: :atoms) |> parse_body
  end
  def parse_salt_resp(%HTTPotion.Response{status_code: code}), do: code

  defp parse_body({:ok, %{return: ret}}) when is_binary(ret), do: {:ok, ret}
  defp parse_body({:ok, %{return: []}}), do: {:gateway_timeout, "Empty return"}
  defp parse_body({:ok, %{return: ret}}) when is_list(ret), do: ret |> check_return
  defp parse_body({:ok, body}), do: {:unprocessable_entity, Poison.encode!(body)}
  defp parse_body({:error, error}), do: {:unsupported_media_type, error}

  defp check_return(ret) do
    {:ok, ret}
  end
end

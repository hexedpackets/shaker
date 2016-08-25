defmodule Shaker do
  @moduledoc """
  Module for making calls to the Salt API and parsing the response.
  The response takes one of the following formats (as JSON):

  ## Simple string result
  {"return": "some string"}

  ## Boolean result
  In this form, each item of the array corresponds to one function issued in the call.
  Each targetted minion has its own key in the dictionary for each function in the array.
  {"return": [{"minion": bool}]}

  ## Dictionary result
  Same as above, but with a dictionary under each minion. Usually used with states.
  {"return": [{"minion": {"name": {"result": bool, ...}}}]}

  """

  require Logger

  defp default_settings do
    settings = Application.get_env(:shaker, :saltapi)
    %{
      client: "local",
      eauth: "pam",
      username: settings[:username],
      password: settings[:password],
    }
  end


  @doc """
  Make a get request to the Salt API server at the given path.
  """
  def salt_call(path), do: salt_call(:get, path)

  @doc """
  Makes a HTTP request to the Salt API server and returns the parsed response.
  """
  def salt_call(method, path, body \\ "", headers \\ [])
  def salt_call(method, path, body, headers) when is_binary(body) do
    settings = Application.get_env(:shaker, :saltapi)
    url = settings[:url] |> Path.join(path)
    timeout = :shaker |> Application.get_env(:saltapi) |> Keyword.get(:timeout)

    Logger.debug "Sending #{inspect body} to #{url} with headers #{inspect headers}"

    resp = HTTPotion.request(method, url, [body: body, headers: headers, timeout: timeout])

    Logger.debug "SaltAPI response for #{path}: #{inspect resp}"
    resp |> parse_salt_resp
  end
  def salt_call(method, path, body, headers) do
    body = body |> Enum.into(%{})
    body = default_settings |> Dict.merge(body) |> Poison.encode!

    headers = headers
    |> Enum.into([])
    |> Keyword.put(:"Content-Type", "application/json")
    salt_call(method, path, body, headers)
  end

  @doc """
  Parses an HTTP response from the Salt API into a RESTful entity.
  """
  def parse_salt_resp(%HTTPotion.Response{status_code: 200, body: body}) do
    body |> Poison.decode |> parse_body
  end
  def parse_salt_resp(%HTTPotion.Response{status_code: code}), do: code

  defp parse_body({:ok, %{"return" => ret}}) when is_binary(ret), do: {:ok, ret}
  defp parse_body({:ok, %{"return" => []}}), do: {:gateway_timeout, "Empty return"}
  defp parse_body({:ok, %{"return" => cmd_returns}}) when is_list(cmd_returns), do: {check_commands(cmd_returns), %{"return" => cmd_returns}}
  defp parse_body({:ok, body}), do: {:unprocessable_entity, Poison.encode!(body)}
  defp parse_body({:error, error}), do: {:unsupported_media_type, error}

  defp check_commands(commands, acc \\ [])
  defp check_commands([], acc) do
    Logger.debug "Accumulated checks: #{inspect acc}"
    {_good_returns, bad_returns} = Keyword.pop(acc, :ok)
    case bad_returns do
      [] -> :ok
      _ -> :internal_server_error
    end
  end
  defp check_commands([command_return | commands], acc) do
    Logger.debug "Checking comman_return: #{inspect command_return}"
    check = command_return |> Dict.values |> check_return
    {_, acc} = Keyword.get_and_update(acc, check, fn(val) -> create_or_append(val, command_return) end)
    Logger.debug "Checking '#{inspect command_return}': #{check}"
    check_commands(commands, acc)
  end

  defp check_return([]), do: :ok
  defp check_return([result | _rest]) when is_binary(result), do: :error
  defp check_return([false | _rest]), do: :error
  defp check_return([true | rest]), do: check_return(rest)
  defp check_return([%{"result" => false} | _rest]), do: :error
  defp check_return([%{"result" => true} | rest]), do: check_return(rest)
  #defp check_return([%{result: false} | _rest]), do: :error
  #defp check_return([%{result: true} | rest]), do: check_return(rest) # successful cmd.run_all
  defp check_return([%{"retcode" => 0} | rest]), do: check_return(rest) # failed cmd.run_all
  defp check_return([%{"retcode" => _} | rest]), do: :error
  defp check_return([ret = %{} | rest]) do
    ret |> Dict.values |> Enum.concat(rest) |> check_return
  end
  defp check_return([result | rest]) when is_list(result) do
    result |> Enum.concat(rest) |> check_return
  end

  @doc """
  Returns a tuple of {username, password} for authenticating with the Salt API.
  The values used are based on the type of auth specified in the request headers to Shaker.
  """
  def auth_info(%{"x-auth-type" => "form"}, body), do: form_auth(body)
  def auth_info(%{"x-auth-type" => auth}, _body), do: {:error, "#{auth} is not a valid auth type"}
  def auth_info(headers, body) do
    headers |> Dict.put("x-auth-type", "form") |> auth_info(body)
  end

  defp form_auth(%{"username" => user, "password" => pass}), do: {user, pass}
  defp form_auth(body) do
    Logger.debug "body: #{inspect body}"
    {:error, "No valid auth found"}
  end

  defp create_or_append(nil, val), do: {nil, [val]}
  defp create_or_append(l, val) when is_list(l), do: {l, [val | l]}
end

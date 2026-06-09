defmodule CfsJksAs.External.Geni.Auth do
    require Logger

  @authorize_url "https://sandbox.geni.com/platform/oauth/authorize"
  @token_url "https://sandbox.geni.com/platform/oauth/request_token"

  @doc """
  Builds the Geni OAuth authorization URL and opens it in the system browser.

  Returns `{:ok, url}` so callers can also handle the URL themselves.
  """

  def authorize(client_id \\ nil, redirect_uri \\ nil) do
    with {:ok, client_id} <- get_client_id(client_id),
         {:ok, redirect_uri} <- get_redirect_uri(redirect_uri) do
      params =
        URI.encode_query(%{
          client_id: client_id,
          redirect_uri: redirect_uri,
          response_type: "code",
          dispaly: "web"
        })

      url = "#{@authorize_url}?#{params}"
      Logger.info("[GeniAuth] Opening browser for Geni login: #{url}")
      open_browser(url)
      {:ok, url}
    end
  end

  @doc """
  Exchange the authorization code returned by Geni for an access token.
   This is the code the application gets after authorization on the browser and
   redirects back to the application on success.

  Returns {:ok, token_map} | {:error, reason}
  where token_map has: access_token, refresh_token, expires_in
  """

  def get_access_token(code, client_id \\ nil, secret \\ nil, redirect \\ nil) do
    response =
      with {:ok, client_id} <- get_client_id(client_id),
           {:ok, app_secret} <- get_app_secret(secret),
           {:ok, redirect_uri} <- get_redirect_uri(redirect) do
        params =
          URI.encode_query(%{
            client_id: client_id,
            client_secret: app_secret,
            redirect_uri: redirect_uri,
            code: code,
            grant_type: "authorization_code"
          })

        url = "#{@token_url}?#{params}"

        Req.get(url)
      end

    case response do
      {:ok, %Req.Response{status: 200, body: token}} ->

      Logger.info("Fetching access token successful.Token #{token["access_token"]}")

      {:ok, token}

      {:ok, %Req.Response{status: status, body: body}} ->
      reason  = extract_reason(body)
      Logger.error("Fetching acess token failed with status #{status}: #{inspect(reason)} ")

       {:error, reason}

    end
  end

  defp get_client_id(client_id) do
    client_id =
      client_id || System.get_env("GENI_CLIENT_ID")

    case client_id do
      nil -> {:error, "missing geni client_id"}
      client_id -> {:ok, client_id}
    end
  end

  defp get_redirect_uri(redirect_uri) do
    redirect_uri =
      redirect_uri ||
        System.get_env("GENI_REDIRECT_URI")

    case redirect_uri do
      nil -> {:error, "missing geni redirect_uri"}
      redirect_uri -> {:ok, redirect_uri}
    end
  end

  defp get_app_secret(app_secret) do
    app_secret =
      app_secret || System.get_env("GENI_APP_SECRET")

    case app_secret do
      nil -> {:error, "missing geni_ app_secret"}
      app_secret -> {:ok, app_secret}
    end
  end

  def open_browser(url) do
    case :os.type() do
      {:unix, :darwin} -> System.cmd("open", [url])
      {:unix, _} -> System.cmd("xdg-open", [url])
      {:win32, _} -> System.cmd("cmd", ["/c", "start", url])
    end
  end

  # TODO, --- extract the errors from html body
  defp extract_reason(body) do
    IO.inspect body
    "failed"
  end
end

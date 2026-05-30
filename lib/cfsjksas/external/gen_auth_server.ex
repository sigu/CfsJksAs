defmodule CfsJksAs.External.GeniAuthServer do
  require Logger

  @authorize_url "https://www.geni.com/platform/oauth/authorize"
  @token_url "https://www.geni.com/platform/oauth/request_token"
  @profile_url "https://www.geni.com/api/profile"

  # @doc """
  # Build the authorization URL to redirect the user to Geni
  # """
  def authorize_url(client_id \\ nil, redirect_uri \\ nil) do
    with {:ok, client_id} <- get_client_id(client_id),
         {:ok, redirect_uri} <- get_redirect_uri(redirect_uri) do
      # params =
      #   URI.encode_query(%{
      #     client_id: client_id,
      #     redirect_uri: redirect_uri,
      #     response_type: "code",
      #     scope: "read_profile"
      #   })
      # "#{@authorize_url}?#{params}"
      params = [client_id: client_id,
          redirect_uri: redirect_uri,
          response_type: "token",
          scope: "read_profile"
         ]

      Req.get(@authorize_url, form: params, redirect: false)
    end
  end

  defp get_client_id(client_id) do
    client_id = client_id || System.get_env("GENI_CLIENT_ID", "gTN0gtLPb4AC9tGc4Yp5GDqOBl8xDdkKUPh9HYB9")

    case client_id do
      nil -> {:error, "missing geni client_id"}
      client_id -> {:ok, client_id}
    end
  end

  defp get_redirect_uri(redirect_uri) do
    redirect_uri = redirect_uri || System.get_env("GENI_REDIRECT_URI", "http://localhost:4000/callback")

    case redirect_uri do
      nil -> {:error, "missing geni redirect_uri"}
      redirect_uri -> {:ok, redirect_uri}
    end
  end
end

# @doc """
# Exchange authorization code for access token. This is the code the application
# gets after authorization on the browser and redirects back to the application on success.
# """

# def exchange_code(code) do
#   response =
#    with {:ok, client_id} <- get_client_id(),
#        {:ok, app_secret} <- get_app_secret(),
#        {:ok, redirect_uri} <- get_redirect_uri() do

#       Req.get!(@token_url,
#         params: [
#           client_id: client_id,
#           client_secret: app_secret,
#           redirect_uri: redirect_uri,
#           code: code,
#           grant_type: "authorization_code"
#         ]
#       )
#   end

#   case response.status do
#     200 ->
#       body = response.body

#       if Map.has_key?(body, "access_token") do
#         Logger.info("Geni, Token request successful")
#         {:ok, body}
#       else
#         Logger.error("Token request failed")

#         {:error, body["error_description"] || "Unknown error from Geni"}
#       end

#     status ->
#       Logger.error("Token request failed")
#       {:error, "Token request failed with HTTP #{status}"}
#   end
# end

# @doc """
# Fetch the authenticated user's profile using the access token
# """
# def fetch_profile(access_token) do
#   response =
#     Req.get!(@profile_url,
#       headers: [{"Authorization", "Bearer #{access_token}"}]
#     )

#   case response.status do
#     200 -> {:ok, response.body}
#     401 -> {:error, "Unauthorized — token may be invalid or expired"}
#     status -> {:error, "Profile request failed with HTTP #{status}"}
#   end
# end

# defp get_app_secret(app_secret) do
#   app_secret = app_secret || System.get_env("GENI_APP_SECRET")

#   case app_secret do
#     nil -> {:error, "missing geni_ app_secret"}
#     app_secret -> {:ok, app_secret}
#   end
# end

# case response.status do
#   200 ->
#     body = response.body

#     if Map.has_key?(body, "access_token") do
#       {:ok, body}
#       Logger.info("Geni, login successful")
#     else
#       Logger.error("Geni login failed")

#       {:error, body["error_description"] || body["error"] || "Unknown error"}
#     end

#   status ->
#     Logger.error("Geni login failed with HTTP #{status}")
#     IO.inspect(response.body)
#     {:error, "HTTP #{status}: #{inspect(response.body)}"}
# end

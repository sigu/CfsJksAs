defmodule CfsJksAs.External.Geni.Client do
  require Logger

  @profile_url "https://sandbox.geni.com/api/profile"

  @doc """
  Fetch the authenticated user's profile using the access token
  """
  def fetch_profile(access_token) do
    response =
      Req.get!(@profile_url,
        headers: [{"Authorization", "Bearer #{access_token}"}]
      )
    #add logger
    case response.status do
      200 -> {:ok, response.body}
      401 -> {:error, "Unauthorized — token may be invalid or expired"}
      status -> {:error, "Profile request failed with HTTP #{status}"}
    end
  end
end

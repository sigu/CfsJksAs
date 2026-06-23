defmodule CfsjksasWeb.Geni.AuthLive do
  use CfsjksasWeb, :live_view
  require Logger

  alias CfsJksAs.External.Geni.Auth
  alias CfsJksAs.External.Geni.Session_Store

  @impl true
  def mount(%{"code" => code, "expires_in" => expires_in}, _session, socket) do
    case Auth.get_access_token(code) do
      {:ok, token} ->
        Session_Store.start_link(token)
        query_string = URI.encode_query(token)
        url = "/geni/auth/success" <> "?" <> query_string

        {:ok, push_navigate(socket, to: url)}

      {:error, reason} ->
        {:ok, push_navigate(socket, to: "/geni/auth/fail?error=reason")}
    end
  end

  def mount(%{"status" => "unauthorized", "message" => msg}, _session, socket) do
    error_msg = "Geni authorization was cancelled: #{msg}"
    {:ok, push_navigate(socket, to: "/geni/auth/fail?error=#{error_msg}")}
  end

  # Fallback for unexpected params
  def mount(_params, _session, socket) do
    error_msg = "Invalid or missing authorization parameters."
    {:ok, push_navigate(socket, to: "/geni/auth/fail?error=error_msg")}
  end
end

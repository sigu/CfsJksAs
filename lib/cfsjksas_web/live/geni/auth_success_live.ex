defmodule CfsjksasWeb.Geni.AuthSuccessLive do
  use CfsjksasWeb, :live_view
  require Logger

  def mount(params, session, socket) do
    expires_in = format_expires_in(params["expires_in"])

    {:ok,
     socket
     |> assign(:access_token, params["access_token"])
     |> assign(:expires_in, expires_in)
     |> assign(:refresh_token, params["refresh_token"])}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start min-h-screen bg-white font-sans p-4 pt-20">
      <!-- Success Icon -->
      <div class="flex items-center justify-center w-16 h-16 rounded-full border-4 border-emerald-600 mb-6">
        <svg
          class="w-8 h-8 text-emerald-600"
          fill="none"
          stroke="currentColor"
          stroke-width="3.5"
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"></path>
        </svg>
      </div>
      
    <!-- Heading -->
      <h1 class="text-3xl font-bold mb-3">
        Authentication complete
      </h1>

      <div class="flex flex-col gap-4 mb-8 text-sm">
        <!-- Expiry Row -->
        <div class="flex items-center py-1.5 text-slate-500 border-t border-slate-100">
          <span>The token expires in {@expires_in}</span>
        </div>
        
    <!-- Access Token Row -->
        <div class="flex items-center justify-between gap-4 py-1.5">
          Token:
          <code
            id="access_token"
            data-value={@access_token}
            class="ml-2 px-1.5 py-0.5 bg-slate-100 rounded font-mono text-slate-800 text-xs break-all"
          >
            {@access_token}
          </code>

          <button
            phx-click={JS.dispatch("phx:copy", to: "#access_token")}
            class="flex items-center gap-1 text-xs font-medium text-emerald-600 hover:text-emerald-700 transition-colors shrink-0"
            title="Copy Token"
          >
            Copy
          </button>
        </div>
        
    <!-- Refresh Token Row -->
        <div class="flex items-center justify-between gap-4 py-1.5 border-t border-slate-100">
          Refresh token:
          <code
            id="refresh_token"
            data-value={@refresh_token}
            class="ml-2 px-1.5 py-0.5 bg-slate-100 rounded font-mono text-slate-800 text-xs break-all"
          >
            {@refresh_token}
          </code>
          <button
            phx-click={JS.dispatch("phx:copy", to: "#refresh_token")}
            class="flex items-center gap-1 text-xs font-medium text-emerald-600 hover:text-emerald-700 transition-colors shrink-0"
            title="Copy Refresh Token"
          >
            Copy
          </button>
        </div>
      </div>
      
    <!-- Subtext -->
      <p class="text-base text-gray-500 font-normal">
        You may now close this window
      </p>
    </div>
    """
  end

  def format_expires_in(seconds) do
    seconds = String.to_integer(seconds)

    hours = div(seconds, 3600)
    remaining_seconds = rem(seconds, 3600)

    minutes = div(remaining_seconds, 60)
    seconds = rem(remaining_seconds, 60)

    min_word = if minutes == 1, do: "min", else: "mins"
    sec_word = if seconds == 1, do: "second", else: "seconds"

    "#{hours}hrs #{minutes} #{min_word}, #{seconds} #{sec_word}"
  end
end

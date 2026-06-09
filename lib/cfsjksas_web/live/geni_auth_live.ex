defmodule CfsjksasWeb.GeniAuthLive do
  use CfsjksasWeb, :live_view
  require Logger

  alias CfsJksAs.External.Geni.Auth
  alias CfsJksAs.External.Geni.Session_Store

  @impl true
  def mount(%{"code" => code, "expires_in" => expires_in}, _session, socket) do
    unless has_existing_token?(code) do
      get_access_code(code, socket)
    else
      {:ok,
       socket
       |> assign(:status, :success)
       |> assign(:error, nil)}
    end
  end

  def mount(%{"status" => "unauthorized", "message" => msg}, _session, socket) do
    {:ok,
     socket
     |> assign(:status, :error)
     |> assign(:error, "Geni authorization was cancelled: #{msg}")
     |> assign(:has_token, false)}
  end

  # Fallback for unexpected params
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:status, :error)
     |> assign(:error, "Invalid or missing authorization parameters.")}
  end



  # TODO -------Implement the close pop up  button functionality

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Fullscreen dimmed backdrop — acts as the "popup" container --%>
    <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-2xl shadow-2xl p-8 max-w-sm w-full mx-4 text-center">
        <%= if @status == :success do %>
          <%!-- Success icon --%>
          <div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
            <svg
              class="h-8 w-8 text-green-600"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          </div>

          <h2 class="text-xl font-semibold text-gray-900 mb-2">
            Connected to Geni
          </h2>
          <p class="text-sm text-gray-500 mb-6">
            Your Geni account has been successfully authenticated.
            You can close this page and return to the app.
          </p>

          <button class="w-full rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white
                   hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500
                   focus:ring-offset-2 transition-colors">
            Close page
          </button>
        <% else %>
          <%!-- Error icon --%>
          <div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-red-100">
            <svg
              class="h-8 w-8 text-red-600"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>

          <h2 class="text-xl font-semibold text-gray-900 mb-2">
            Authentication failed
          </h2>
          <p class="text-sm text-red-500 mb-6">
            {@error}
          </p>

          <button
            phx-click="close"
            class="w-full rounded-lg bg-gray-200 px-4 py-2.5 text-sm font-medium text-gray-700
                   hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-400
                   focus:ring-offset-2 transition-colors"
          >
            Close page
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp has_existing_token?(code) do
    Process.whereis(:session_store) && Session_Store.get_code()
  end

  defp get_access_code(code, socket) do
    Logger.info("Fetching access token......")

    case Auth.get_access_token(code) do
      {:ok, token} ->
        new_map = Map.put(token, "code", code)
        Session_Store.start_link(new_map)

        {:ok,
         socket
         |> assign(:status, :success)
         |> assign(:error, nil)}

      {:error, reason} ->
        {:ok,
         socket
         |> assign(:status, :error)
         |> assign(:error, "Authentication failed: #{inspect(reason)}")}
    end
  end
end

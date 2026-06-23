defmodule CfsjksasWeb.Geni.AuthFailLive do
  use CfsjksasWeb, :live_view
  require Logger

  def mount(%{"error" => error_msg}, _session, socket) do
    {:ok, assign(socket, error: error_msg)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start min-h-screen bg-white font-sans p-4 pt-20">
      <!-- fail Icon -->
      <div class="flex items-center justify-center w-16 h-16 rounded-full rounded-full bg-red-100">
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

      <h1 class="text-xl font-semibold text-gray-900 mb-2">
        Authentication failed
      </h1>
      <p class="text-sm text-red-500 mb-6">
        {@error}
      </p>
    </div>
    """
  end
end

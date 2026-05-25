defmodule CfsjksasWeb.AnalysisLive.ParentLinkStats do
      require IEx
    use CfsjksasWeb, :live_view

  @impl true
  @doc """
    summarize parent links across all ancestors
  """
  def mount(_params, _session, socket) do
    data = Cfsjksas.Trace.AllParents.analyze()

    {:ok,
     socket
     |> assign(:data, data)

    }

  end

end

defmodule CfsjksasWeb.AnalysisLive.ParentLinks do
      require IEx
    use CfsjksasWeb, :live_view

  @impl true
  @doc """
    show a person, their parents, and links
  """
  def mount(params, _session, socket) do
    # default to CFS if no parameter for another person
    person_of_interest = if Map.has_key?(params, "p") do
      String.to_existing_atom(params["p"])
    else
      :p0001
    end
    parent_links = Cfsjksas.Trace.ParentLinks.analyze(person_of_interest)
    {:ok,
     socket
     |> assign(:id_a, to_string(person_of_interest))
     |> assign(:name, parent_links.name_dates)
     |> assign(:werelate, parent_links.werelate)
     |> assign(:db_father, parent_links.db_father)
     |> assign(:db_mother, parent_links.db_mother)
     |> assign(:father_name, parent_links.father_name)
     |> assign(:mother_name, parent_links.mother_name)
     |> assign(:werelate_father, parent_links.werelate_father)
     |> assign(:werelate_mother, parent_links.werelate_mother)

    }

  end

end

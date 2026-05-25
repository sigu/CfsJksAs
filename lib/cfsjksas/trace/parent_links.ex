defmodule Cfsjksas.Trace.ParentLinks do
  @moduledoc """
    look at individual and parents in db and on websites
  """
  require IEx

  defstruct [
    :id_a,
    :person_a,
    :name_dates,
    :geni, # text of link, :no_link
    :myheritage, # text of link, :no_link
    :werelate, # text of link, :no_link
    :wikitree, # text of link, :no_link
    :db_father, # :ship, nil (ie :no_father), [id_a of father]
    :father_name, # text name of father for display
    :geni_father, # no_father, link to father
    :myheritage_father, # no_father, link to father
    :werelate_father, # no_father, link to father
    :wikitree_father, # no_father, link to father
    :db_mother, # :ship, nil (ie :no_mother), [id_a of mother]
    :mother_name, # text name of mother for display
    :geni_mother, # no_mother, link to mother
    :myheritage_mother, # no_mother, link to mother
    :werelate_mother, # no_mother, link to mother
    :wikitree_mother, # no_mother, link to mother
  ]

  def analyze(id_a) do
    %Cfsjksas.Trace.ParentLinks{id_a: id_a}
    |> add_person_a()
    |> add_name_dates()
    |> add_db_father()
    |> add_db_mother()
    |> add_werelate()
    |> get_werelate_father()
    |> get_werelate_mother()

  end

  defp add_person_a(parent_links) do
    %Cfsjksas.Trace.ParentLinks{parent_links | person_a: Cfsjksas.Ancestors.AgentStores.get_person_a(parent_links.id_a)}
  end

  defp add_name_dates(parent_links) do
    %Cfsjksas.Trace.ParentLinks{parent_links | name_dates: Cfsjksas.Ancestors.Person.get_name_dates(parent_links.person_a)}
  end

  defp add_db_father(parent_links) do
    case Map.has_key?(parent_links.person_a, :father) do
      false ->
        # no father key
        %Cfsjksas.Trace.ParentLinks{parent_links | db_father: "NA", father_name: "NA"}
      true ->
        case parent_links.person_a.father do
          nil ->
            %Cfsjksas.Trace.ParentLinks{parent_links | db_father: "NA", father_name: "NA"}
          _ ->
            father_name = parent_links.person_a.father
            |> Cfsjksas.Ancestors.AgentStores.get_person_a()
            |> Cfsjksas.Ancestors.Person.get_name_dates()

            %Cfsjksas.Trace.ParentLinks{parent_links | db_father: parent_links.person_a.father,
                                                  father_name: father_name}
        end
    end
  end

  defp add_db_mother(parent_links) do
    case Map.has_key?(parent_links.person_a, :mother) do
      false ->
        # no mother key
        %Cfsjksas.Trace.ParentLinks{parent_links | db_mother: "NA", mother_name: "NA"}
      true ->
        case parent_links.person_a.mother do
          nil ->
            %Cfsjksas.Trace.ParentLinks{parent_links | db_mother: "NA", mother_name: "NA"}
          _ ->
            mother_name = parent_links.person_a.mother
            |> Cfsjksas.Ancestors.AgentStores.get_person_a()
            |> Cfsjksas.Ancestors.Person.get_name_dates()

            %Cfsjksas.Trace.ParentLinks{parent_links | db_mother: parent_links.person_a.mother,
                                                  mother_name: mother_name}
        end
    end
  end

  defp add_werelate(parent_links) do
    case Map.has_key?(parent_links.person_a.links, :werelate) do
      false ->
        # no werelate key
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate: :no_link}
      true ->
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate: parent_links.person_a.links.werelate}
    end
  end

  defp get_werelate_father(%Cfsjksas.Trace.ParentLinks{db_father: :ship} = parent_links) do
    # don't bother tracing werelate father since immigrant on ship terminates line
    %Cfsjksas.Trace.ParentLinks{parent_links | werelate_father: :ship}
  end
  defp get_werelate_father(%Cfsjksas.Trace.ParentLinks{werelate: :no_link} = parent_links) do
    # no link so can't trace
    %Cfsjksas.Trace.ParentLinks{parent_links | werelate_father: :no_link}
  end
  defp get_werelate_father(%Cfsjksas.Trace.ParentLinks{} = parent_links) do
    case Cfsjksas.Links.Utils.screen_scrape(:werelate, parent_links.werelate) do
      [] ->
        # no parents
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate_father: "NA"}
      [werelate_father, _werelate_mother] ->
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate_father: werelate_father}
      oops ->
        IEx.pry()
    end
  end

  defp get_werelate_mother(%Cfsjksas.Trace.ParentLinks{db_mother: :ship} = parent_links) do
    # don't bother tracing werelate mother since immigrant on ship terminates line
    %Cfsjksas.Trace.ParentLinks{parent_links | werelate_mother: :ship}
  end
  defp get_werelate_mother(%Cfsjksas.Trace.ParentLinks{werelate: :no_link} = parent_links) do
    # no link so can't trace
    %Cfsjksas.Trace.ParentLinks{parent_links | werelate_mother: :no_link}
  end
  defp get_werelate_mother(%Cfsjksas.Trace.ParentLinks{} = parent_links) do
    case Cfsjksas.Links.Utils.screen_scrape(:werelate, parent_links.werelate) do
      [] ->
        # no parents
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate_mother: "NA"}
      [_werelate_father, werelate_mother] ->
        %Cfsjksas.Trace.ParentLinks{parent_links | werelate_mother: werelate_mother}
      oops ->
        IEx.pry()
    end
  end

end

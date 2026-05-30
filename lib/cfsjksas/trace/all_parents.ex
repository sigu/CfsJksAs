defmodule Cfsjksas.Trace.AllParents do
  @moduledoc """
    recurse thru all ancestors collecting parent/link stats
  """

  require IEx

  defstruct [
    quantity_ancestors: 0,

    quantity_db_fathers: 0,
    quantity_wr_fathers: 0,

    quantity_db_fathers_wr: 0,
    quantity_db_fathers_nwr: 0,
    quantity_ndb_fathers_wr: 0,
    quantity_ndb_fathers_nwr: 0,
    quantity_db_fathers_ship: 0,

    quantity_db_mothers: 0,
    quantity_wr_mothers: 0,

    quantity_db_mothers_wr: 0,
    quantity_db_mothers_nwr: 0,
    quantity_ndb_mothers_wr: 0,
    quantity_ndb_mothers_nwr: 0,
    quantity_db_mothers_ship: 0,

    id_list_db_father_ship: [],
    id_list_db_mother_ship: [],

    id_list_db_wr_father: [], # has db father, has werelate father
    id_list_db_wr_mother: [], # has db mother, has werelate mother
    id_list_db_nwr_father: [], # has db father, no werelate father
    id_list_db_nwr_mother: [], # has db mother, no werelate mother
    id_list_ndb_wr_father: [], # no db father, has werelate father
    id_list_ndb_wr_mother: [], # no db mother, has werelate mother
    id_list_ndb_nwr_father: [], # no db father, no werelate father
    id_list_ndb_nwr_mother: [],  # no db mother, no werelate mother
  ]

  def analyze() do
    people_ids = Cfsjksas.Ancestors.AgentStores.all_a_ids()
    %Cfsjksas.Trace.AllParents{}
    |> analyze(people_ids)
  end

  defp analyze(%Cfsjksas.Trace.AllParents{} = counts, []) do
    # done
    counts
  end
  defp analyze(%Cfsjksas.Trace.AllParents{} = counts, [id_a | rest_id_a]) do
IO.inspect(id_a)
    data = Cfsjksas.Trace.ParentLinks.analyze(id_a)
IO.inspect({id_a, data.db_father, data.db_mother})
    analyze(counts, id_a, data)
    |> analyze(rest_id_a)
  end

  defp analyze(counts, id_a, %Cfsjksas.Trace.ParentLinks{db_father: :ship} = data) do
    # father is immigrant so na
    %Cfsjksas.Trace.AllParents{counts | quantity_ancestors: counts.quantity_ancestors + 1,
                                        quantity_db_fathers_ship: counts.quantity_db_fathers_ship + 1,
                                        id_list_ndb_nwr_father: [id_a | counts.id_list_ndb_nwr_father],
    }
  end
  defp analyze(counts, id_a, %Cfsjksas.Trace.ParentLinks{db_father: "NA", werelate_father: :no_link} = data) do
    # neither db nor we relate father - increment overall quantity, and no/no count and list
    %Cfsjksas.Trace.AllParents{counts | quantity_ancestors: counts.quantity_ancestors + 1,
                                        quantity_ndb_fathers_nwr: counts.quantity_ndb_fathers_nwr + 1,
                                        id_list_ndb_nwr_father: [id_a | counts.id_list_ndb_nwr_father],
    }
  end
  defp analyze(counts, id_a, %Cfsjksas.Trace.ParentLinks{db_father: "NA"} = data) do
    # no db father but has werelate father - increment overall quantity, and no/yes count and list
    %Cfsjksas.Trace.AllParents{counts | quantity_ancestors: counts.quantity_ancestors + 1,
                                        quantity_ndb_fathers_wr: counts.quantity_ndb_fathers_wr + 1,
                                        id_list_ndb_wr_father: [id_a | counts.id_list_ndb_wr_father],
    }
  end
  defp analyze(counts, id_a, %Cfsjksas.Trace.ParentLinks{werelate_father: :no_link} = data) do
    # has db father but no werelate father - increment overall quantity, and yes/no count and list
    %Cfsjksas.Trace.AllParents{counts | quantity_ancestors: counts.quantity_ancestors + 1,
                                        quantity_db_fathers_nwr: counts.quantity_db_fathers_nwr + 1,
                                        id_list_db_nwr_father: [id_a | counts.id_list_db_nwr_father],
    }
  end
  def analyze(counts, id_a, rest_id_a, %Cfsjksas.Trace.ParentLinks{} = data) do
    # has db father and wr father, increment overall quantity, and yes/yes count and list
    %Cfsjksas.Trace.AllParents{counts | quantity_ancestors: counts.quantity_ancestors + 1,
                                        quantity_db_fathers_wr: counts.quantity_ndb_fathers_wr + 1,
                                        id_list_db_wr_father: [id_a | counts.id_list_ndb_wr_father],
    }
  end

end

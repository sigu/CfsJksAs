defmodule CfsJksAs.External.Geni.Session_Store do
use Agent

 def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: :session_store)
  end

  def get_token, do: Agent.get(:session_store, &Map.get(&1, "access_token"))
  def get_code, do: Agent.get(:session_store, &Map.get(&1, "code"))

end

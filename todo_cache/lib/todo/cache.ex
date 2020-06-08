defmodule Todo.Cache do
    use GenServer
    @moduledoc """
    Cache process that maps names of
    Todo managing server processes to
    their PIDs.
    """

    @impl GenServer
    def init(_) do
        {:ok, %{}}
    end
    
    @impl GenServer
    def handle_call({:server_process, todo_list_name}, _, todo_servers) do
        # TODO : left off listing 7.2
    end
end
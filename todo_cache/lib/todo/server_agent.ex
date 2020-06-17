defmodule Todo.ServerAgent do
    use Agent, restart: :temporary
    @moduledoc """
    A server process that stores the state of
    a single Todo.List and has functionality for
    adding, updating, deleting and retrieving
    Todo entries.
    """

    # interface functions
    def start_link(name) do
        Agent.start_link(
            fn ->
                IO.puts("Starting Todo server process for list: #{name}")
                {name, Todo.Database.get(name) || Todo.List.new()}
            end,
            name: via_tuple(name)
        )
    end

    defp via_tuple(name) do
        Todo.ProcessRegistry.via_tuple({__MODULE__, name})
    end

    def entries(todo_server, date) do
        Agent.get(
            todo_server,
            fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
        )
    end

    def add_entry(todo_server, new_entry) do
        Agent.cast(todo_server, fn {name, todo_list} ->
            new_list = Todo.List.add_entry(todo_list, new_entry)
            Todo.Database.store(name, new_list)
            {name, new_list}
        end)
    end

    def update_entry(todo_server, id, updater) do
        Agent.cast(todo_server, fn {name, todo_list} ->
            {name, Todo.List.update_entry(todo_list, id, updater)}
        end)
    end

    def delete_entry(todo_server, id) do
        Agent.cast(todo_server, fn {name, todo_list} ->
            {name, Todo.List.delete_entry(todo_list, id)}
        end)
    end
end
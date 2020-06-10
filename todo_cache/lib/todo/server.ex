defmodule Todo.Server do
    use GenServer
    @moduledoc """
    A server process that stores the state of
    a single Todo.List and has functionality for
    adding, updating, deleting and retrieving
    Todo entries.
    """

    # interface functions
    def start(name) do
        GenServer.start(Todo.Server, name)
    end

    def entries(todo_server, date) do
        GenServer.call(todo_server, {:entries, date})
    end

    def add_entry(todo_server, new_entry) do
        GenServer.cast(todo_server, {:add_entry, new_entry})
    end

    def update_entry(todo_server, id, updater) do
        GenServer.cast(todo_server, {:update_entry, id, updater})
    end

    def delete_entry(todo_server, id) do
        GenServer.cast(todo_server, {:delete_entry, id})
    end

    # implement plug functions for GenServer
    @impl GenServer
    def init(name) do
        send(self(), :real_init)
        {:ok, name}
    end

    @impl GenServer
    @doc """
    Method used to load the Todo list for this server
    from disk based on the name, if it exists.
    This is handled using a message passed to the process
    so that the caller does not block when creating new 
    Todo.Server processes.
    """
    def handle_info(:real_init, name) do
        {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}}
    end

    @impl GenServer
    def handle_call({:entries, date}, _, {name, state}) do
        {:reply, Todo.List.entries(state, date), {name, state}}
    end

    @impl GenServer
    def handle_cast({:add_entry, new_entry}, {name, state}) do
        new_list = Todo.List.add_entry(state, new_entry)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
    end

    @impl GenServer
    def handle_cast({:update_entry, id, updater}, {name, state}) do
        {:noreply, {name, Todo.List.update_entry(state, id, updater)}}
    end

    @impl GenServer
    def handle_cast({:delete_entry, id}, {name, state}) do
        {:noreply, {name, Todo.List.delete_entry(state, id)}}
    end
end
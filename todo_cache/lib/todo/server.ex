defmodule Todo.Server do
    use GenServer
    @moduledoc """
    A server process that stores the state of
    a single Todo.List and has functionality for
    adding, updating, deleting and retrieving
    Todo entries.
    """

    # interface functions
    def start do
        GenServer.start(Todo.Server, nil)
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
    def init(_) do
        {:ok, Todo.List.new()}
    end

    @impl GenServer
    def handle_call({:entries, date}, _, state) do
        {:reply, Todo.List.entries(state, date), state}
    end

    @impl GenServer
    def handle_cast({:add_entry, new_entry}, state) do
        {:noreply, Todo.List.add_entry(state, new_entry)}
    end

    @impl GenServer
    def handle_cast({:update_entry, id, updater}, state) do
        {:noreply, Todo.List.update_entry(state, id, updater)}
    end

    @impl GenServer
    def handle_cast({:delete_entry, id}, state) do
        {:noreply, Todo.List.delete_entry(state, id)}
    end
end
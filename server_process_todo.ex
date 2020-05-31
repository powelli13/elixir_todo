defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init()
            loop(callback_module, initial_state)
        end)
    end

    def call(server_pid, request) do
        send(server_pid, {:call, request, self()})

        receive do
            {:response, response} ->
                response
        end
    end

    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end

    defp loop(callback_module, current_state) do
        receive do
            {:call, request, caller} ->
                {response, new_state} =
                    callback_module.handle_call(
                        request,
                        current_state
                    )
                
                send(caller, {:response, response})

                loop(callback_module, new_state)

            {:cast, request} ->
                new_state =
                    callback_module.handle_cast(
                        request,
                        current_state
                    )

                loop(callback_module, new_state)
        end
    end
end

defmodule TodoServer do

    def start() do
        ServerProcess.start(TodoServer)
    end

    def init() do
        TodoList.new()
    end

    def handle_cast({:add_entry, new_entry}, todo_list) do
        TodoList.add_entry(todo_list, new_entry)
    end

    def handle_cast({:update_entry, id, updater}, todo_list) do
        TodoList.update_entry(todo_list, id, updater)
    end

    def handle_cast({:delete_entry, id}, todo_list) do
        TodoList.delete_entry(todo_list, id)
    end

    def handle_call({:entries, date}, todo_list) do
        {TodoList.entries(todo_list, date), todo_list}
    end

    def add_entry(server_pid, new_entry) do
        ServerProcess.cast(server_pid, {:add_entry, new_entry})
    end

    def update_entry(server_pid, id, updater) do
        ServerProcess.cast(server_pid, {:update_entry, id, updater})
    end

    def delete_entry(server_pid, id) do
        ServerProcess.cast(server_pid, {:delete_entry, id})
    end

    def entries(server_pid, date) do
        ServerProcess.call(server_pid, {:entries, date})
    end
end

defmodule TodoList do
    defstruct auto_id: 1, entries: %{}

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            fn entry, todo_list_acc ->
                add_entry(todo_list_acc, entry)
            end
        )
    end

    def entries(todo_list, date) do
        todo_list.entries
        |> Stream.filter(fn {_, entry} -> entry.date == date end)
        |> Enum.map(fn {_, entry} -> entry end)
    end

    def add_entry(todo_list, entry) do
        entry = Map.put(entry, :id, todo_list.auto_id)

        new_entries = Map.put(
            todo_list.entries,
            todo_list.auto_id,
            entry
        )

        %TodoList{todo_list |
            :auto_id => todo_list.auto_id + 1,
            :entries => new_entries
        }
    end

    def update_entry(todo_list, %{} = new_entry) do
        update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
    end

    def update_entry(todo_list, id, updater) do
        case Map.fetch(todo_list.entries, id) do
            :error ->
                todo_list

            {:ok, old_entry} ->
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater.(old_entry)
                new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def delete_entry(todo_list, deleted_id) do
        %TodoList{todo_list | entries: Map.delete(todo_list.entries, deleted_id)}
    end
end
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

defmodule TodoList.CsvImporter do
    def import(file) do
        File.stream!(file)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Stream.map(&String.replace(&1, "\r", ""))
        |> Stream.map(&String.split(&1, ","))
        |> Stream.map(
            fn [date | title_list] ->
                {date, hd(title_list)}
            end)
        |> Stream.map(
            fn {date_string, title} ->
                {String.split(date_string, "/"), title}
            end)
        |> Stream.map(
            fn {date_string_pieces, title} ->
                {Enum.map(date_string_pieces, &String.to_integer/1), title}
            end)
        |> Stream.map(
            fn {[year | [month | day]], title} ->
                %{
                    date: Date.new(year, month, hd(day)), 
                    title: title
                }
            end)
        |> TodoList.new()
    end
end

defmodule TodoServer do
    use GenServer

    def start do
        GenServer.start(TodoServer, nil, name: __MODULE__)
    end

    def entries(date) do
        GenServer.call(__MODULE__, {:entries, date})
    end

    def add_entry(new_entry) do
        GenServer.cast(__MODULE__, {:add_entry, new_entry})
    end

    def update_entry(id, updater) do
        GenServer.cast(__MODULE__, {:update_entry, id, updater})
    end

    def delete_entry(id) do
        GenServer.cast(__MODULE__, {:delete_entry, id})
    end

    # implement plug functions for GenServer
    @impl GenServer
    def init(_) do
        {:ok, TodoList.new()}
    end

    @impl GenServer
    def handle_call({:entries, date}, _, state) do
        {:reply, TodoList.entries(state, date), state}
    end

    @impl GenServer
    def handle_cast({:add_entry, new_entry}, state) do
        {:noreply, TodoList.add_entry(state, new_entry)}
    end

    @impl GenServer
    def handle_cast({:update_entry, id, updater}, state) do
        {:noreply, TodoList.update_entry(state, id, updater)}
    end

    @impl GenServer
    def handle_cast({:delete_entry, id}, state) do
        {:noreply, TodoList.delete_entry(state, id)}
    end
end

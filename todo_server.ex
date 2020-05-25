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
    def start() do
        spawn(fn -> loop(TodoList.new()) end)
    end

    def add_entry(todo_server, new_entry) do
        send(todo_server, {:add_entry, new_entry})
    end

    def update_entry(todo_server, id, updater) do
        send(todo_server, {:update_entry, id, updater})
    end

    def delete_entry(todo_server, id) do
        send(todo_server, {:delete_entry, id})
    end

    def entries(todo_server, date) do
        send(todo_server, {:entries, self(), date})

        receive do
            {:todo_entries, entries} -> entries
        after
            5000 -> {:error, :timeout}
        end
    end

    defp process_message(todo_list, {:add_entry, new_entry}) do
        TodoList.add_entry(todo_list, new_entry)
    end

    defp process_message(todo_list, {:update_entry, id, updater}) do
        TodoList.update_entry(todo_list, id, updater)
    end

    defp process_message(todo_list, {:delete_entry, id}) do
        TodoList.delete_entry(todo_list, id)
    end

    defp process_message(todo_list, {:entries, caller, date}) do
        send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
        todo_list
    end

    defp loop(todo_list) do
        new_todo_list = 
            receive do
                message ->
                    process_message(todo_list, message)
            end

        loop(new_todo_list)
    end
end
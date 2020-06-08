defmodule Todo.List do
    defstruct auto_id: 1, entries: %{}
    @moduledoc """
    A data abstraction used to contain and
    manipulate multiple Todo entries.
    """

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %Todo.List{},
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

        %Todo.List{todo_list |
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
                %Todo.List{todo_list | entries: new_entries}
        end
    end

    def delete_entry(todo_list, deleted_id) do
        %Todo.List{todo_list | entries: Map.delete(todo_list.entries, deleted_id)}
    end
end
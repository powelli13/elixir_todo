defmodule Todo.Cache do
    @moduledoc """
    Cache supervisor that dynamically
    supervises Todo.Server processes.
    """

    def start_link do
        IO.puts("Starting todo cache process.")

        DynamicSupervisor.start_link(
            name: __MODULE__,
            strategy: :one_for_one
        )
    end

    def server_process(todo_list_name) do
        case start_child(todo_list_name) do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
        end
    end

    defp start_child(todo_list_name) do
        DynamicSupervisor.start_child(
            __MODULE__,
            {Todo.Server, todo_list_name}
        )
    end

    def child_spec(_arg) do
        %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, []},
            type: :supervisor
        }
    end
end
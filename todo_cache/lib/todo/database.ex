defmodule Todo.Database do
    @moduledoc """
    Supervisor for the Todo.DatabaseWorker
    processes.
    """

    @pool_size 3
    @db_folder "./persist"

    def start_link do
        IO.puts("Starting database supervisor.")
        File.mkdir_p!(@db_folder)

        children = Enum.map(1..@pool_size, &worker_spec/1)

        Supervisor.start_link(children, strategy: :one_for_one)
    end

    def child_spec(_) do
        %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, []},
            type: :supervisor
        }
    end

    defp worker_spec(worker_id) do
        default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
        Supervisor.child_spec(default_worker_spec, id: worker_id)
    end

    def store(key, data) do
        key
        |> choose_worker()
        |> Todo.DatabaseWorker.store(key, data)
    end

    def get(key) do
        key
        |> choose_worker()
        |> Todo.DatabaseWorker.get(key)
    end

    defp choose_worker(key) do
        :erlang.phash2(key, @pool_size) + 1
    end
end
defmodule Todo.Database do
    use GenServer
    @moduledoc """
    Persists Todo lists to disk using keys
    as the file name.
    """

    @db_folder "./persist"

    def start do
        GenServer.start(__MODULE__, nil,
            name: __MODULE__
        )
    end

    def store(key, data) do
        GenServer.cast(__MODULE__, {:store, key, data})
    end

    def get(key) do
        GenServer.call(__MODULE__, {:get, key})
    end

    @impl GenServer
    def init(_) do
        File.mkdir_p!(@db_folder)
        workers = %{
            0 => Todo.DatabaseWorker.start(@db_folder),
            1 => Todo.DatabaseWorker.start(@db_folder),
            2 => Todo.DatabaseWorker.start(@db_folder)
        }

        {:ok, workers}
    end

    defp choose_worker(workers, file_name) do
        key = :erlang.phash2(file_name, 3)

        case Map.fetch(workers, key) do
            {:ok, worker} -> worker
            :error -> raise "Invalid key: #{file_name}"
        end
    end

    @impl GenServer
    def handle_cast({:store, key, data}, workers) do
        worker = choose_worker(workers, key)
        Todo.DatabaseWorker.store(worker, key, data)

        {:noreply, workers}
    end

    @impl GenServer
    def handle_call({:get, key}, _, workers) do
        worker = choose_worker(workers, key)
        {:ok, data} = Todo.DatabaseWorker.get(worker, key)

        #TODO may need to give caller to workers to reply
        {:reply, data, workers}
    end
end
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
        {:ok, worker_one} = Todo.DatabaseWorker.start(@db_folder)
        {:ok, worker_two} = Todo.DatabaseWorker.start(@db_folder)
        {:ok, worker_three} = Todo.DatabaseWorker.start(@db_folder)

        workers = %{
            0 => worker_one,
            1 => worker_two,
            2 => worker_three
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
        choose_worker(workers, key)
        |> Todo.DatabaseWorker.store(key, data)

        {:noreply, workers}
    end

    @impl GenServer
    def handle_call({:get, key}, _, workers) do
        data = choose_worker(workers, key)
        |> Todo.DatabaseWorker.get(key)
        
        {:reply, data, workers}
    end
end
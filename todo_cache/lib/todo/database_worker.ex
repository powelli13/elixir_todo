defmodule Todo.DatabaseWorker do
    use GenServer

    def start(folder) do
        GenServer.start(Todo.DatabaseWorker, folder)
    end

    def get(worker, key) do
        GenServer.call(
            worker,
            {:get, key}
        )
    end

    def store(worker, key, data) do
        GenServer.cast(
            worker,
            {:store, key, data}
        )
    end

    @impl GenServer
    def init(folder) do
        {:ok, folder}
    end

    @impl GenServer
    def handle_cast({:store, key, data}, folder) do
        IO.inspect "#{self()}: storing #{key}"

        key
        |> file_name(folder)
        |> File.write!(:erlang.term_to_binary(data))
        
        {:noreply, folder}
    end

    # TODO may need to use caller here?
    @impl GenServer
    def handle_call({:get, key}, _, folder) do
        IO.inspect "#{self()}: retrieving #{key}"

        data = case File.read(file_name(key, folder)) do
            {:ok, contents} -> :erlang.binary_to_term(contents)
            _ -> nil
        end

        {:reply, data, folder}
    end

    defp file_name(key, folder) do
        Path.join(folder, to_string(key))
    end
end
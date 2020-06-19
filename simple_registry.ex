defmodule SimpleRegistry do
    use GenServer

    def start_link() do
        GenServer.start_link(
            __MODULE__,
            nil,
            name: __MODULE__
        )
    end

    def register(name) do
        GenServer.call(
            __MODULE__,
            {:register, name}
        )
    end

    def whereis(name) do
        GenServer.call(
            __MODULE__,
            {:whereis, name}
        )
    end

    @impl GenServer
    def init(_) do
        Process.flag(:trap_exit, true)

        {:ok, %{}}
    end

    @impl GenServer
    def handle_info({:EXIT, pid, _}, map) do
        keys_to_drop = Enum.filter(
            map,
            fn {_, map_pid} ->
                map_pid == pid
            end)
        |> Enum.map(
            fn {key, _} ->
                key
            end)
            
        {:noreply, Map.drop(map, keys_to_drop)}
    end

    @impl GenServer
    def handle_call({:register, name}, {caller_pid, _}, map) do
        Process.link(caller_pid)

        {response, new_map} = case Map.get(map, name) do
            nil ->
                {:ok, Map.put(map, name, caller_pid)}
            _ ->
                {:error, map}
        end

        {:reply, response, new_map}
    end

    @impl GenServer
    def handle_call({:whereis, name}, _, map) do
        {:reply, Map.get(map, name), map}
    end
end
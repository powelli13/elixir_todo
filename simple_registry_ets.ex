defmodule SimpleRegistryETS do
    use GenServer

    def start_link() do
        GenServer.start_link(
            __MODULE__,
            nil,
            name: __MODULE__
        )
    end

    def register(name) do
        Process.link(
            Process.whereis(__MODULE__)
        )

        if :ets.insert_new(__MODULE__, {name, self()}) do
            :ok
        else
            :error
        end
    end

    def whereis(name) do
        case :ets.lookup(__MODULE__, name) do
            [] ->
                nil
            [{^name, pid}] ->
                pid
        end
    end

    @impl GenServer
    def init(_) do
        Process.flag(:trap_exit, true)
        :ets.new(__MODULE__, [:named_table, :public, :set])

        {:ok, nil}
    end

    @impl GenServer
    def handle_info({:EXIT, pid, _}, _) do
        :ets.match_delete(__MODULE__, {:_, pid})

        {:noreply, nil}
    end
end
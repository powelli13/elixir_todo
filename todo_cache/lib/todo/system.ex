defmodule Todo.System do
    use Supervisor
    @moduledoc """
    Supervisor module to oversee the entire
    Todo System.
    """

    def start_link do
        Supervisor.start_link(__MODULE__, nil)
    end

    @impl Supervisor
    def init(_) do
        Supervisor.init(
            [Todo.Cache], 
            strategy: :one_for_one
        )
    end
end
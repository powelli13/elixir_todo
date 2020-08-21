defmodule KeyValueStore do
  # This is the function callers will use to fire up the long running store
  def start() do
    # spawn returns the PID of our long running store process
    spawn(fn -> loop(%{}) end)
  end

  # Private function that will continually receive the commands
  defp loop(store_state) do
    new_state = receive do
      {:get, key, caller_pid} ->
        # Map.get returns nil when key doesn't exist
        send(caller_pid,
          {:response, Map.get(store_state, key)})

        # return the state in order to preserve it in the next loop call
        store_state

      {:put, key, value} ->
        # Map.put will simply overwrite the key if given duplicate
        # Map.put will return the updated map so we have our new_state
        # to loop with
        Map.put(store_state, key, value)

      # catch all to process garbage messages so our mailbox doesn't overfill
      # comment out below and use :observer.start() to checkout the filling
      # queue if there's time
      _ ->
        store_state
    end

    loop(new_state)
  end

  # Public functions used to interact with the long running process
  # get function will block the caller process when calling receive
  # note that this is the caller receiving, not the longer running
  # process created by the spawn call inside of start
  def get(store_pid, key) do
    send(store_pid, {:get, key, self()})

    receive do
      {:response, value} ->
        value
    after
      1_000 ->
        "Timeout"
    end
  end

  # put function used to store values
  # simply callss and forgets
  def put(store_pid, key, value) do
    send(store_pid, {:put, key, value})
  end
end
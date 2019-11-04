defmodule Purr.MainServer do
  use GenServer

  def start_link(_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, []}
  end

  def handle_call(:get_data, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:update_data, new_state}, _state) do
    {:noreply, new_state}
  end
end

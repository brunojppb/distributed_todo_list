defmodule Todo.KeyValue do
  use GenServer

  # Start a GenServer that holds a reference to a ETS table
  # the ETS table will live until this GenServer process dies
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true]
    )
    {:ok, nil}
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

end

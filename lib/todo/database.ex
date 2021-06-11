defmodule Todo.Database do
  require Logger
  use GenServer

  @db_folder "./store"

  def start do
    Logger.info("Starting Database")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    worker_pid = GenServer.call(__MODULE__, {:choose_worker, key})
    Todo.DatabaseWorker.store(worker_pid, key, data)
  end

  def get(key) do
    worker_pid = GenServer.call(__MODULE__, {:choose_worker, key})
    Todo.DatabaseWorker.get(worker_pid, key)
  end

  @impl GenServer
  def init(_) do
    workers_map = init_workers()
    Logger.info("Databse Workers started...")
    {:ok, workers_map}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers_map) do
    worker = choose_worker(workers_map, key)
    {:reply, worker, workers_map}
  end

  defp init_workers() do
    for index <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {index - 1, pid}
    end
  end

  defp choose_worker(workers_map, key) do
    map_key = :erlang.phash(key, map_size(workers_map) - 1)
    Logger.info("Map key: #{map_key} - Workers: #{inspect(workers_map)}")
    worker = Map.get(workers_map, map_key)
    Logger.info("Worker pid: #{inspect(worker)}")
    worker
  end

end

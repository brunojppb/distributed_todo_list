defmodule Todo.Database do
  require Logger

  @pool_size 3
  @db_folder "./store"

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.store(worker_id, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.get(worker_id, key)
      end
    )
  end

end

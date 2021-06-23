defmodule Todo.Server do
  require Logger
  use GenServer, restart: :temporary

  # This will serve to instruct the process
  # to notify us of any idle time.
  # If this timeout is passed as the last tuple value
  # to GenServer calls, our process will be notified
  # via `handle_info/2` with :timeout
  @expiry_idle_timeout :timer.seconds(10)

  def start_link(list_name) do
    GenServer.start_link(
      __MODULE__,
      list_name,
      name: via_tuple(list_name)
    )
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(list_name) do
    Logger.info("Starting server for list #{list_name}")
    # Try to fetch it from disk. Fallback to empty list
    initial_list = Todo.Database.get(list_name) || Todo.List.new()
    {
      :ok,
      {list_name, initial_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_todolist = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_todolist)
    {
      :noreply,
      {list_name, new_todolist},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {list_name, todo_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_info(:timeout, {list_name, todo_list}) do
    Logger.info("Stopping Server due to indle time of #{@expiry_idle_timeout}")
    {:stop, :normal, {list_name, todo_list}}
  end
end

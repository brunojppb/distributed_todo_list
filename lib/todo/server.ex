defmodule Todo.Server do
  require Logger
  use Agent, restart: :temporary

  def start_link(list_name) do
    Agent.start_link(
      fn ->
        Logger.info("Starting Todo Server for #{list_name}")
        {list_name, Todo.Database.get(list_name) || Todo.List.new()}
      end,
      name: via_tuple(list_name)
    )
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end

  def add_entry(todo_server, new_entry) do
    Agent.cast(todo_server, fn {list_name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(list_name, new_list)
      {list_name, new_list}
    end)
  end

  def entries(todo_server, date) do
    Agent.get(
      todo_server,
      fn {_list_name, todo_list} ->
        Todo.List.entries(todo_list, date)
      end
    )
  end

  def all_entries(todo_server) do
    Agent.get(
      todo_server,
      fn {_list_name, todo_list} ->
        Todo.List.all_entries(todo_list)
      end
    )
  end
end

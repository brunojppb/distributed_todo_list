defmodule DistributedTodoTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache_pid} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache_pid, "bob")

    assert bob_pid != Todo.Cache.server_process(cache_pid, "alice")
    assert bob_pid == Todo.Cache.server_process(cache_pid, "bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2021-10-03], title: "Elixir Lecture"})
    entries = Todo.Server.entries(alice, ~D[2021-10-03])
    assert [%{date: ~D[2021-10-03], title: "Elixir Lecture"}] = entries
  end

end

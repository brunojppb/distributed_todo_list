# Distributed Todo

Start `iex` and execute the following:

```elixir
# Start the cache server
{:ok, cache} = Todo.Cache.start()

# Start the todo server for the given todolist
server = Todo.Cache.server_process(cache, "this_is_cool")

# Query for entries
Todo.Server.entries(server, ~D[2020-10-10])

# Add new entries
Todo.Server.add_entry(server, %{date: ~D[2021-01-01], title: "Go for a walk"})
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/distributed_todo](https://hexdocs.pm/distributed_todo).

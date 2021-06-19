# Distributed Todo

Start `iex` and execute the following:

```elixir
# Start the cache server
Todo.System.start_link()

# Start the todo server for the given todolist
server = Todo.Cache.server_process(cache, "this_is_cool")

# Query for entries
Todo.Server.entries(server, ~D[2020-10-10])

# Add new entries
Todo.Server.add_entry(server, %{date: ~D[2021-01-01], title: "Go for a walk"})
```

## Testing fault tolerance

```elixir
# First, find out the pid of a database worker via our custom registry
[{worker_pid, _}] = Registry.lookup(Todo.ProcessRegistry, {Todo.DatabaseWorker, 2})

# now kill the process
Process.exit(worker_pid, :kill)

# You should see the process with ID 2 restarting 
# and getting back to the registry with the following log
19:51:54.508 [info]  Starting DB Worker with id 2

# Querying for this worker with the same id
# should give you a different pid now
[{worker_pid, _}] = Registry.lookup(Todo.ProcessRegistry, {Todo.DatabaseWorker, 2})
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/distributed_todo](https://hexdocs.pm/distributed_todo).

defmodule Todo.Metrics do
  use Task
  require Logger

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  defp loop do
    Process.sleep(:timer.seconds(50))
    Logger.info("Metrics: #{inspect(collect_metrics())}")
    loop()
  end

  defp collect_metrics do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end

end

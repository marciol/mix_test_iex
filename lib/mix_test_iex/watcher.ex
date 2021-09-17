defmodule MixTestIEx.Watcher do
  alias MixTestIEx.TaskSupervisor
  alias MixTestIEx.Runner

  def start(paths, watcher_cmd \\ "fswatch") do
    Task.Supervisor.start_child(
      TaskSupervisor,
      fn ->
        cmd = "#{watcher_cmd} #{paths}"
        port = Port.open({:spawn, cmd}, [:binary, :exit_status])
        watch_loop(port)
      end,
      restart: :transient
    )
  end

  def stop(pid) do
    Task.Supervisor.terminate_child(
      TaskSupervisor,
      pid
    )
  end

  defp watch_loop(port) do
    receive do
      {^port, {:data, _msg}} ->
        Task.Supervisor.start_child(
          TaskSupervisor,
          fn ->
            Runner.run(:stale)
          end,
          restart: :transient
        )

        watch_loop(port)
    end
  end
end

defmodule MixTestIEx.Controller do
  use GenServer

  alias MixTestIEx.Watcher
  alias MixTestIEx.Runner
  alias MixTestIEx.TaskSupervisor
  alias MixTestIEx.ExUnitObserver

  @controller __MODULE__
  @timeout :infinity

  def start_link(paths) do
    state = %{watcher: nil, lock: false, paths: paths, subscribed_observers: []}
    GenServer.start_link(@controller, state, name: @controller)
  end

  def watch_tests do
    GenServer.cast(@controller, :watch_tests)
  end

  def observe_tests do
    pid = self()
    GenServer.cast(@controller, {:subscribe_observer, pid})

    observer_tests_loop(pid)
  end

  defp observer_tests_loop(pid) do
    input =
      spawn(fn ->
        send(pid, {:input, self(), IO.gets(:stdio, "")})
      end)

    receive do
      {:test_result, msg} ->
        [:green, msg, :reset]
        |> IO.ANSI.format_fragment(true)
        |> IO.iodata_to_binary()
        |> IO.write()

        observer_tests_loop(pid)

      {:input, ^input, msg} ->
        cond do
          msg == "s\n" ->
            :ok

          msg == "a\n" ->
            run_all_tests()
            observer_tests_loop(pid)

          true ->
            observer_tests_loop(pid)
        end

      _msg ->
        :ok
    end
  end

  def unwatch_tests do
    GenServer.cast(@controller, :unwatch_tests)
  end

  def run_all_tests do
    GenServer.cast(@controller, {:run, :all})
  end

  def run_failed_tests do
    GenServer.cast(@controller, {:run, :failed})
  end

  def run_stale_tests do
    GenServer.cast(@controller, {:run, :stale})
  end

  def unlock do
    GenServer.cast(@controller, :unlock)
  end

  def test_notify(test_result) do
    GenServer.cast(@controller, {:test_notify, test_result})
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    ExUnit.start(autorun: false, formatters: [ExUnitObserver])
    Code.compiler_options(ignore_module_conflict: true)

    if is_fswatch_intalled() do
      {:ok, state}
    else
      raise "fswatch must be installed!"
    end
  end

  @impl true
  def handle_cast(:watch_tests, %{lock: true} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast(:watch_tests, state) do
    paths = Enum.join(state.paths, " ")

    {:ok, pid} = Watcher.start(paths)

    Process.monitor(pid)

    {:noreply, %{state | watcher: pid, lock: true}}
  end

  @impl true
  def handle_cast(:unwatch_tests, %{watcher: pid} = state) do
    if is_nil(pid) or not Process.alive?(pid) do
      IO.puts("Watcher not running!")
    else
      Watcher.stop(pid)
    end

    {:noreply, %{state | watcher: nil, lock: false}}
  end

  @impl true
  def handle_cast(:unlock, state) do
    {:noreply, %{state | lock: false}}
  end

  @impl true
  def handle_cast({:subscribe_observer, observer}, %{subscribed_observers: observers} = state) do
    {:noreply, %{state | subscribed_observers: [observer | observers]}}
  end

  @impl true
  def handle_cast({:test_notify, test_result}, %{subscribed_observers: observers} = state) do
    for observer <- observers,
        do: send(observer, {:test_result, test_result})

    {:noreply, state}
  end

  @impl true
  def handle_cast({:run, _mode}, %{lock: true} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:run, mode}, %{lock: false} = state) do
    Task.Supervisor.start_child(
      TaskSupervisor,
      fn ->
        do_run(mode)
      end,
      restart: :transient
    )

    {:noreply, %{state | lock: true}}
  end

  @impl true
  def handle_info({:reply, from}, state) do
    GenServer.reply(from, :ok)
    {:noreply, %{state | lock: false}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp do_run(mode) do
    Runner.run(mode)
  after
    GenServer.cast(@controller, :unlock)
  end

  defp is_fswatch_intalled do
    cmd = Process.get(:shell_command) || (&System.shell/1)

    case cmd.("command -v fswatch") do
      {_msg, 0} -> true
      _ -> false
    end
  end
end

defmodule MixTestIEx.ExUnitObserver do
  use GenServer

  @impl true
  def init(config) do
    {:ok, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: nil} = _test}, config) do
    MixTestIEx.Controller.test_notify(success("."))

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:excluded, _}} = _test}, config) do
    MixTestIEx.Controller.test_notify(invalid("."))

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:skipped, _}} = _test}, config) do
    MixTestIEx.Controller.test_notify(skipped("."))

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:invalid, _}} = _test}, config) do
    MixTestIEx.Controller.test_notify(invalid("."))

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, _failures}} = _test}, config) do
    MixTestIEx.Controller.test_notify(failure("."))

    {:noreply, config}
  end

  @impl true
  def handle_cast(_, config) do
    {:noreply, config}
  end

  defp success(msg) do
    colorize(:green, msg)
  end

  defp invalid(msg) do
    colorize(:yellow, msg)
  end

  defp skipped(msg) do
    colorize(:yellow, msg)
  end

  defp failure(msg) do
    colorize(:red, msg)
  end

  defp colorize(escape, string) do
    [escape, string, :reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.iodata_to_binary()
  end
end

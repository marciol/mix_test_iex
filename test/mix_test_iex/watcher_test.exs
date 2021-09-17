defmodule MixTestIEx.WatcherTest do
  use ExUnit.Case
  doctest MixTestIEx.Watcher

  test "must raise an error if fswatch isn't installed" do
    assert_raise RuntimeError, fn ->
      Process.put(:shell_command, fn _cmd -> {"", 1} end)
      MixTestIEx.Watcher.init(%{})
      Process.delete(:shell_command)
    end
  end
end

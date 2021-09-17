defmodule MixTestIEx.ControllerTest do
  use ExUnit.Case
  doctest MixTestIEx.ControllerTest

  test "must raise an error if fswatch isn't installed" do
    assert_raise RuntimeError, "fswatch must be installed!", fn ->
      Process.put(:shell_command, fn _cmd -> {"", 1} end)
      MixTestIEx.Controller.init(%{})
      Process.delete(:shell_command)
    end
  end
end

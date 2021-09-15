defmodule MixTestIEx do
  use ExUnit.Case
  doctest MixTestIEx

  test "greets the world" do
    assert IexTestWatch.hello() == :world
  end
end

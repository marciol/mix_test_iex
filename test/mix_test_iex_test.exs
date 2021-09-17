defmodule MixTestIEx do
  use ExUnit.Case
  doctest MixTestIEx

  # test if it unlock when an error occurs
  # test if it unlock when on error on observer occurs
  # test if it let zoombie processes
  # verify if executes only once a time

  test "greets the world" do
    assert IexTestWatch.hello() == :world
  end

  @pending
  test "verify is fswatch is installed"
end

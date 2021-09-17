defmodule Mix.Tasks.Test.Iex do
  defdelegate run(args), to: MixTestIEx
end

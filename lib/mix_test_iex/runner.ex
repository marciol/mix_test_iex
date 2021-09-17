defmodule MixTestIEx.Runner do
  def run(mode) do
    IEx.Helpers.recompile()

    # Reset config
    ExUnit.configure(
      exclude: [],
      include: [],
      only_test_ids: nil
    )

    Code.required_files()
    |> Enum.filter(&String.ends_with?(&1, "_test.exs"))
    |> Code.unrequire_files()

    args =
      case mode do
        :all ->
          []

        :failed ->
          ["--failed"]

        :stale ->
          ["--stale"]
      end

    Mix.Tasks.Test.run(args)
  end
end

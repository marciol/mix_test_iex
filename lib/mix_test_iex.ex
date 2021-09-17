defmodule MixTestIEx do
  def run(args \\ []) do
    Mix.env(:test)
    put_config(args)

    Application.ensure_all_started(:mix_test_iex)

    ensure_iex_is_running!()
  end

  defp put_config(args) do
    {_, paths} = OptionParser.parse!(args, switches: [])

    paths =
      if length(paths) == 0 do
        ["lib", "test"]
      else
        paths
      end

    Application.put_env(:mix_test_iex, :paths, paths)
  end

  defp ensure_iex_is_running! do
    unless IEx.started?() do
      Mix.raise("mixt test.iex need a running iex shell, please run \"iex -S mix test.iex\"")
    end
  end
end

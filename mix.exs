defmodule MixTestIEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_test_iex,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "mix test.iex",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    "Automatically run tests when files change in a iex friendly way"
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/marciol/mix_test_iex"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

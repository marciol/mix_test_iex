defmodule MixTestIEx.Application do
  @moduledoc false

  use Application

  alias MixTestIEx.Controller

  @impl true
  def start(_type, _args) do
    paths = Application.get_env(:mix_test_iex, :paths, [])

    children = [
      {Controller, paths},
      {Task.Supervisor, name: MixTestIEx.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: MixTestIEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

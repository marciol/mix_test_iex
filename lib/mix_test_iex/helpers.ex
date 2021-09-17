defmodule MixTestIEx.Helpers do
  alias MixTestIEx.Controller

  defdelegate a, to: Controller, as: :run_all_tests
  defdelegate f, to: Controller, as: :run_failed_tests
  defdelegate s, to: Controller, as: :run_stale_tests
  defdelegate w, to: Controller, as: :watch_tests
  defdelegate uw, to: Controller, as: :unwatch_tests
  defdelegate o, to: Controller, as: :observe_tests
end

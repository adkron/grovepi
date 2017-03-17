defmodule GrovePi.Buttons.Registry do
  def start_link do
    Registry.start_link(:duplicate, __MODULE__, partitions: System.schedulers_online)
  end

  def dispatch({:released, pin} = message), do: do_dispatch(message)
  def dispatch({:pressed, pin} = message), do: do_dispatch(message)

  defp do_dispatch(message) do
    Registry.dispatch __MODULE__, message, fn(listeners) ->
      for {pid, _} <- listeners, do: send(pid, message)
    end
  end

  def register({:pressed, pin} = message), do: do_register(message)
  def register({:released , pin} = message), do: do_register(message)

  defp do_register(message) do
    Registry.register(__MODULE__, message, [])
  end
end

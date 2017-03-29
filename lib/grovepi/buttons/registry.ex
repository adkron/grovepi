defmodule GrovePi.Buttons.Registry do
  @moduledoc false

  def start_link do
    Registry.start_link(:duplicate, __MODULE__, partitions: System.schedulers_online)
  end

  @spec dispatch(GrovePi.Buttons.message) :: :ok
  def dispatch(message) do
    Registry.dispatch __MODULE__, message, fn(listeners) ->
      for {pid, args} <- listeners, do: _dispatch(pid, message, args)
    end
  end

  defp _dispatch(pid, message, :ok) do
    send(pid, message)
  end

  defp _dispatch(pid, _message, {module, function, args}) do
    apply(module, function, [pid | args])
  end

  @spec register(GrovePi.Buttons.message, :ok | mfa) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(message, event \\ :ok) do
    Registry.register(__MODULE__, message, event)
  end
end

defmodule GrovePi.Buttons.Registry do
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

  defp _dispatch(pid, message, {module, function, args}) do
    apply(module, function, [pid | args])
  end

  @spec register(GrovePi.Buttons.message) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(message), do: _register(message, :ok)

  @spec register(GrovePi.Buttons.message, mfa) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(message, mfa), do: _register(message, mfa)

  @spec _register(GrovePi.Buttons.message, :ok | mfa) :: {:ok, pid} | {:error, {:already_registered, pid}}
  defp _register(message, event) do
    Registry.register(__MODULE__, message, event)
  end
end

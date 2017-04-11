defmodule GrovePi.Utils do
  @moduledoc false

  @spec notify_change(GrovePi.Buttons.message) :: :ok
  def notify_change(message) do
    Registry.dispatch(GrovePi.SubscriberRegistry, message, fn(listeners) ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  @spec subscribe(GrovePi.Buttons.message) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(message) do
    Registry.register(GrovePi.SubscriberRegistry, message, :ok)
  end
end

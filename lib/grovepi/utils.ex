defmodule GrovePi.Utils do
  @moduledoc false

  def pin_name(pin) do
    {:via, Registry, {GrovePi.PinRegistry, pin}}
  end

  @spec notify_change(GrovePi.Buttons.message) :: :ok
  def notify_change(message) do
    Registry.dispatch(GrovePi.SubscriberRegistry, message, fn(listeners) ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  def subscribe(message) do
    Registry.register(GrovePi.SubscriberRegistry, message, :ok)
  end
end

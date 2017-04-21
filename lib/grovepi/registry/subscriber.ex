defmodule GrovePi.Registry.Subscriber do
  @moduledoc false

  @type event :: atom
  @type package :: any
  @type registration :: {GrovePi.pin, event}
  @type message :: {GrovePi.pin, event, package}

  @spec start_link(Registry.registry) :: Supervisor.on_start
  def start_link(prefix, opts \\ []) do
    opts = Keyword.put(opts, :id, :subscriber_registry)
    Registry.start_link(:duplicate, registry(prefix), opts)
  end

  @spec notify_change(atom, GrovePi.Buttons.message) :: :ok
  def notify_change(prefix, {pin, event, _} = message) do
    Registry.dispatch(registry(prefix), {pin, event}, fn(listeners) ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  @spec subscribe(atom, registration) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(prefix, message) do
    Registry.register(registry(prefix), message, :ok)
  end

  defp registry(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end
end

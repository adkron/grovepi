defmodule GrovePi.Registry.Subscriber do
  @registry __MODULE__

  @spec start_link(Registry.registry) :: Supervisor.on_start
  def start_link(registry \\ @registry, opts \\ []) do
    opts = Keyword.put(opts, :id, :subscriber_registry)
    Registry.start_link(:duplicate, registry, opts)
  end

  @spec notify_change(GrovePi.Buttons.message) :: :ok
  def notify_change(message) do
    Registry.dispatch(GrovePi.Registry.Subscriber, message, fn(listeners) ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  @spec subscribe(GrovePi.Buttons.message) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(message) do
    Registry.register(GrovePi.Registry.Subscriber, message, :ok)
  end
end

defmodule GrovePi.Registry.Subscriber do
  @registry __MODULE__

  @spec start_link(Registry.registry) :: Supervisor.on_start
  def start_link(registry \\ @registry, opts \\ []) do
    opts = Keyword.put(opts, :id, :subscriber_registry)
    Registry.start_link(:duplicate, registry, opts)
  end

  @spec notify_change(Registry.registry, GrovePi.Buttons.message) :: :ok
  def notify_change(registry, message) do
    Registry.dispatch(registry, message, fn(listeners) ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  @spec notify_change(GrovePi.Buttons.message) :: :ok
  def notify_change(message) do
    notify_change(@registry, message)
  end

  @spec subscribe(Registery.registry, GrovePi.Buttons.message) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(registry, message) do
    Registry.register(registry, message, :ok)
  end

  @spec subscribe(GrovePi.Buttons.message) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(message) do
    subscribe(@registry, message)
  end
end

defmodule GrovePi.Registry.Pin do
  @registry __MODULE__

  @spec start_link(Registry.registry) :: Supervisor.on_start
  def start_link(registry \\ @registry, opts \\ []) do
    opts = Keyword.put(opts, :id, :pin_registry)
    Registry.start_link(:unique, registry, opts)
  end

  def name(registry, pin) do
    {:via, Registry, {registry, pin}}
  end

  def name(pin) do
    name(@registry, pin)
  end
end

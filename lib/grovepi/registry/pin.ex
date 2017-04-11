defmodule GrovePi.Registry.Pin do
  @registry __MODULE__

  @spec start_link(Registry.registry) :: Supervisor.on_start
  def start_link(registry \\ @registry, opts \\ []) do
    opts = Keyword.put(opts, :id, :pin_registry)
    Registry.start_link(:unique, registry, opts)
  end

  def name(pin, registry \\ @registry) do
    {:via, Registry, {registry, pin}}
  end
end

defmodule GrovePi.Registry.Pin do
  @moduledoc false

  @spec start_link(atom) :: Supervisor.on_start()
  def start_link(prefix, opts \\ []) do
    opts = Keyword.put(opts, :id, :pin_registry)

    Registry.start_link(:unique, registry(prefix), opts)
  end

  def name(prefix, pin) do
    {:via, Registry, {registry(prefix), pin}}
  end

  def registry(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end
end

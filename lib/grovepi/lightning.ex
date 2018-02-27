defmodule GrovePi.Lightning do
  defdelegate child_spec(args), to: GrovePi.Lightning.Supervisor
  @registry GrovePi.Lightning.Registry

  def subscribe(event) do
    Registry.register(@registry, event, [])
  end

  def read do
    GenServer.call(GrovePi.Lightning.Server, :read_cached)
  end

  def read! do
    GenServer.call(GrovePi.Lightning.Server, :read)
  end

  def gain do
    GenServer.call(GrovePi.Lightning.Server, :read_cached).gain
  end

  def gain(setting) do
    GenServer.cast(GrovePi.Lightning.Server, {:set, :gain, setting})
  end

  def last_strike do
    value = GenServer.call(GrovePi.Lightning.Server, :read_cached)
    {value.interrupt, value.distance}
  end

  def notify(%{interrupt: event, distance: distance}) do
    Registry.dispatch(@registry, event, fn entries ->
      for {pid, _} <- entries, do: send pid, {event, distance}
    end)
  end
end

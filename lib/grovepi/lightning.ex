defmodule GrovePi.Lightning do
  @moduledoc """
  Support for AS3935 Lightning Sensor

  The messages subscribed for will be a tuple containing the interrupt
  and the distance reading from the sensor. `{:lightning, 10}`. All
  distances are in kilometers.

      iex> GrovePi.Lightning.start_link([])
      {:ok, pid}
      iex> GrovePi.Lightning.subscribe(:lightning)
      :ok
      iex> flush()
      {:lightning, :out_of_range}
      {:lightning, 10}
      {:lightning, :overhead}

  """
  defdelegate child_spec(args), to: GrovePi.Lightning.Supervisor
  @doc "Start the lightning sensor"
  defdelegate start_link(args), to: GrovePi.Lightning.Supervisor
  @registry GrovePi.Lightning.Registry

  @type interrupt ::
  :none |
  :noise_level_too_high |
  :disturber_detected |
  :lightning

  @type gain :: :indoor | :outdoot

  @type distance ::
  :overhead |
  1..63 |
  :out_of_range

  @doc """
  Subscribe for specific GrovePi.Lightning events
  """
  @spec subscribe(interrupt) :: :ok
  def subscribe(event) do
    Registry.register(@registry, event, [])
  end

  @doc """
  Read cached information from the lightning sensor's last state
  """
  @spec read :: GrovePi.Lightning.Server.t
  def read do
    GenServer.call(GrovePi.Lightning.Server, :read_cached)
  end

  @doc """
  Read straight from the lightning sensor
  """
  @spec read! :: GrovePi.Lightning.Server.t
  def read! do
    GenServer.call(GrovePi.Lightning.Server, :read)
  end

  @doc """
  Check if the current gain is indoor or outdoor
  """
  @spec gain :: gain
  def gain do
    GenServer.call(GrovePi.Lightning.Server, :read_cached).gain
  end

  @doc """
  Change the current gain to indoor or outdoor
  """
  @spec gain(gain) :: :ok
  def gain(setting) do
    GenServer.cast(GrovePi.Lightning.Server, {:set, :gain, setting})
  end

  def notify(%{interrupt: event, distance: distance}) do
    Registry.dispatch(@registry, event, fn entries ->
      for {pid, _} <- entries, do: send pid, {event, distance}
    end)
  end
end

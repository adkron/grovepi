defmodule GrovePi.Relay do
  @moduledoc """
  Conveniences for controlling a [GrovePi Relay](http://wiki.seeed.cc/Grove-Relay/).

  The relay should be connected to a Digital port (e.g. D3). The relay can
  be connected to something with a larger load, i.e appliance or desk lamp,
  which can then be controlled by the
  [GrovePi](https://www.dexterindustries.com/grovepi/).

  ```elixir
  iex> pin = 3
  3
  iex> GrovePi.Relay.initialize(pin)
  :ok
  iex> GrovePi.Relay.on(pin)
  :ok
  iex> GrovePi.Relay.off(pin)
  :ok
  ```
  """

  alias GrovePi.Digital

  @doc """
  Turns off the appliance, lamp, etc. connected to the relay.
  """
  @spec off(GrovePi.pin) :: :ok | {:error, term}
  def off(pin) do
    Digital.write(pin, 0)
  end

  @doc """
  Turns on the appliance, lamp, etc. connected to the relay.
  """
  @spec on(GrovePi.pin) :: :ok | {:error, term}
  def on(pin) do
    Digital.write(pin, 1)
  end

  @doc """
  Sets the pin mode to output. Required prior to using `on/1` or `off/1`.
  """
  @spec initialize(GrovePi.pin) :: :ok | {:error, term}
  def initialize(pin) do
    Digital.set_pin_mode(pin, :output)
  end
end

defmodule GrovePi.IRReflective do
  alias GrovePi.Digital

  use GrovePi.Poller, default_trigger: GrovePi.IRReflective.DefaultTrigger,
  read_type: Digital.level

  @moduledoc """
  Conveniences for working with an Infrared Reflective Sensor.

  Listen for events from a GrovePi IR Reflective sensor. There are two types of
  events by default; close and far. When registering for an event the
  sensor will then send a message of `{pin, :close, %{value: 0}}` or
  `{pin, :far, %{value: 1}}`. The sensor works by polling
  `GrovePi.Digital` on the pin that you have registered to an IR Reflective sensor.

  Example usage:
  ```
  iex> {:ok, button} = GrovePi.IRReflective.start_link(3)
  :ok
  iex> GrovePi.IRReflective.subscribe(3, :close)
  :ok
  iex> GrovePi.IRReflective.subscribe(3, :far)
  :ok
  ```
  """

  def read_value(prefix, pin) do
    Digital.read(prefix, pin)
  end
end

defmodule GrovePi.Sound do
  alias GrovePi.Analog

  use GrovePi.Poller, default_trigger: GrovePi.Sound.HysteresisTrigger,
  read_type: Analog.adc_level

  @moduledoc """
  Conveniences for working with a sound sensor.

  Listen for events from a GrovePi sound module. There are two types of
  events by default; loud and quiet. When registering for an event the sound
  will then send a message of `{pin, :loud, _trigger_date}` or
  `{pin, :quiet, _trigger_data}`. The sound works by polling
  `GrovePi.Analog` on the pin that you have registered to a sound.

  Example usage:
  ```
  iex> {:ok, sound} = GrovePi.Sound.start_link(3)
  :ok
  iex> GrovePi.Sound.subscribe(3, :loud)
  :ok
  iex> GrovePi.Sound.subscribe(3, :quiet)
  :ok
  ```
  """

  def read_value(prefix, pin) do
    Analog.read(prefix, pin)
  end
end

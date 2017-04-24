defmodule GrovePi.Button do
  use GrovePi.Poller, default_trigger: GrovePi.Button.DefaultTrigger, read_type: GrovePi.Digital.level

  @moduledoc """
  Listen for events from a GrovePi button. There are two types of
  events; pressed and released. When registering for an event the button
  will then send a message of `{pin, :pressed, {value: 1}` or
  `{pin, :released, {value: 0}}`. The button works by polling
  `GrovePi.Digital` on the pin that you have registered to a button.

  Example usage:
  ```
  iex> {:ok, button}=GrovePi.Button.start_link(3)
  :ok
  iex> GrovePi.Button.subscribe(3, :pressed)
  :ok
  iex> GrovePi.Button.subscribe(3, :released)
  :ok
  ```
  """

  def read_value(prefix, pin) do
    GrovePi.Digital.read(prefix, pin)
  end
end

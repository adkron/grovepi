defmodule GrovePi.Button do
  alias GrovePi.Digital

  use GrovePi.Poller,
    default_trigger: GrovePi.Button.DefaultTrigger,
    read_type: Digital.level()

  @moduledoc """
  Conveniences for working with a button.

  Listen for events from a GrovePi button. There are two types of
  events by default; pressed and released. When registering for an event the
  button will then send a message of `{pin, :pressed, %{value: 1}` or
  `{pin, :released, %{value: 0}}`. The button works by polling
  `GrovePi.Digital` on the pin that you have registered to a button.

  Example usage:
  ```
  iex> {:ok, button} = GrovePi.Button.start_link(3)
  :ok
  iex> GrovePi.Button.subscribe(3, :pressed)
  :ok
  iex> GrovePi.Button.subscribe(3, :released)
  :ok
  ```
  """

  def read_value(prefix, pin) do
    Digital.read(prefix, pin)
  end
end

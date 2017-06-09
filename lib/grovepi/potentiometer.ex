defmodule GrovePi.Potentiometer do
  alias GrovePi.Analog

  use GrovePi.Poller, default_trigger: GrovePi.Potentiometer.DefaultTrigger,
  read_type: Analog.adc_level

  @moduledoc """
  Conveniences for reading from a potentiometer or rotary angle sensor.

  Listen for events from a GrovePi potentiometer or rotary angle sensor. There
  is only one type of event by default; `:changed`. When registering for an
  event the potentiometer will send a message similar to
  `{pin, :changed, {value: 1}` with the value being a number from 0-1023
  that maps to 0 to 5 volts.  The potentiometer works by polling
  `GrovePi.Analog` on the pin that you have registered to a potentiometer.

  Example usage:
  ```
  iex> {:ok, potentiometer} = GrovePi.Potentiometer.start_link(16)
  :ok
  iex> GrovePi.Potentiometer.subscribe(16, :changed)
  :ok
  ```

  The `GrovePi.Potentiometer.DefaultTrigger` is written so when the value of
  the potentiometer changes, the subscribed process will receive a message in
  the form of `{pid, :changed, %{value: value}`. The message should be
  received using GenServer handle_info/2.

  For example:
  ```
  def handle_info({_pid, :changed, %{value: value}}, state) do
    # do something with `value`
    {:noreply, state}
  end
  ```
  """

  def read_value(prefix, pin) do
    Analog.read(prefix, pin)
  end
end

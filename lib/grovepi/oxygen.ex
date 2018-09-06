defmodule GrovePi.Oxygen do
  alias GrovePi.Analog

  use GrovePi.Poller,
    default_trigger: GrovePi.Oxygen.DefaultTrigger,
    read_type: Analog.adc_level()

  @moduledoc """
  Conveniences for reading from a Oxygen Gas sensor.

  Listen for events from a GrovePi oxygen sensor.  There is only one type
  of event by default `:changed`.  When registering for an event, the sensor
  will send you a message similar to `{pin, :changed, {value: 300}}` where `value`
  is a number from 0-1023 that maps onto a voltage between 0V and 5V.  The sensor
  works by polling `GrovePi.Analog` on the pin that you have registered to a Oxygen
  gas sensor.

  Example usage:
  ```
  iex> {:ok, gas_sensor} = GrovePi.Oxygen.start_link(16)
  :ok
  iex> GrovePi.Oxygen.subscribe(16, changed)
  :ok
  ```

  The `GrovePi.Oxygen.DefaultTrigger` is written so when the value of
  the sensor changes, the subscribed process will receive a message in
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

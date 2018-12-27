defmodule GrovePi.DHT do
  alias GrovePi.Board

  use GrovePi.Poller,
    default_trigger: GrovePi.DHT.DefaultTrigger,
    read_type: GrovePi.Digital.level()

  @moduledoc """
  Conveniences for reading from a DHT sensor.

  Listen for events from a GrovePi DHT (Digital Humidity and Temparature)
  sensor. This module is configured for the DHT11, the blue one, that comes
  with the GrovePi+ Starter Kit. There is only one type of event by default;
  `:changed`. When registering for an event the DHT will send a message in the
  form of `{pin, :changed, %{temp: 11.3, humidity: 45.5}` with the temp and
  humidty being floats. The `GrovePi.DHT` module works by polling
  the pin that you have registered to a DHT sensor.

  Example usage:
  ```
  iex> {:ok, dht} = GrovePi.DHT.start_link(7)
  :ok
  iex> GrovePi.DHT.subscribe(7, :changed)
  :ok
  ```

  The `GrovePi.DHT.DefaultTrigger` is written so when the value of
  the either the temp or humidity changes, the subscribed process will receive
  a message in the form of `{pid, :changed, %{temp: 11.3, humidity: 45.5}`. The
  message should be received using GenServer handle_info/2.

  For example:
  ```
  def handle_info({_pid, :changed, %{temp: temp, humidity: humidity}}, state) do
    # do something with temp and/or humidity
    {:noreply, state}
  end
  ```
  """
  @module_type 0

  def read_value(prefix, pin) do
    with :ok <- Board.send_request(prefix, <<40, pin, @module_type, 0>>),
         <<_, temp::little-float-size(32), humidity::little-float-size(32)>> <-
           Board.get_response(prefix, 9),
         do: {temp, humidity}
  end
end

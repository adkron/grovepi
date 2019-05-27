defmodule GrovePi.Ultrasonic do
  alias GrovePi.Board

  use GrovePi.Poller,
    default_trigger: GrovePi.Ultrasonic.DefaultTrigger,
    read_type: GrovePi.Digital.level()

  @moduledoc """
  Read distance and subscribe to changes from the Grove Ultrasonic Ranger sensor.

  Listen for events from a GrovePi Ultrasonic Ranger
  sensor. This module is configured for the Ultrasonic Ranger, the one that comes
  with the GrovePi+ Starter Kit. There is only one type of event by default;
  `:changed`. When registering for an event the Ultrasonic will send a message in the
  form of `{pin, :changed, %{value: 13}` with the distance as an integer. The 
  `GrovePi.Ultrasonic` module works by polling
  the pin that you have registered to a Ultrasonic sensor.

  Example use:
  ```
  iex> pin = 3
  iex> {:ok, pid} = GrovePi.Ultrasonic.start_link(pin)
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Ultrasonic.read(pin)
  20
  iex> GrovePi.Ultrasonic.read(pin)
  23
  iex> GrovePi.Ultrasonic.subscribe(7, :changed)
  :ok
  ```

  The `GrovePi.Ultrasonic.DefaultTrigger` is written so when the value of
  the ultrasonic sensor changes, the subscribed process will receive
  a message in the form of `{pid, :changed, %{value: 44}`. The
  message should be received using GenServer handle_info/2.

  For example:
  ```
  def handle_info({_pid, :changed, %{value: value}}, state) do
    # do something with value 
    {:noreply, state}
  end
  """

  @type distance :: integer

  @doc false
  @deprecated "Use GrovePi.Ultrasonic.read/1 instead"
  @spec read_distance(GrovePi.pin(), atom) :: distance
  def read_distance(pin, prefix \\ Default) do
    GenServer.call(Pin.name(prefix, pin), :read)
  end

  @doc false
  @spec read_value(atom, GrovePi.pin()) :: distance
  def read_value(prefix, pin) do
    with :ok <- Board.send_request(prefix, <<7, pin, 0, 0>>),
         :ok <- wait_for_sensor(),
         <<_, distance::big-integer-size(16)>> <- Board.get_response(prefix, 3),
         do: distance
  end

  defp wait_for_sensor do
    Process.sleep(60)
  end
end

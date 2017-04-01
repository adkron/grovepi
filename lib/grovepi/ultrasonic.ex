defmodule GrovePi.Ultrasonic do
  @moduledoc """
  Read distance from the Grove Ultrasonic sensor.

  Example use:
  ```
  iex> {:ok, pid}=GrovePi.start_link
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Ultrasonic.read_distance(pid, 2)
  20
  iex> GrovePi.Ultrasonic.read_distance(pid, 2)
  23
  ```
  """

  alias GrovePi.Board

  def read_distance(pin) do
    with :ok <- Board.send_request(<<7, pin, 0, 0>>),
         # Firmware waits for 50 ms to read sensor
         :ok <- Process.sleep(60),
         <<_, distance::big-integer-size(16)>> <- Board.get_response(3),
         do: distance
  end

end

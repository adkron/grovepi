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

  use GrovePi.I2C

  def read_distance(pid, pin) do
    :ok = @i2c.write(pid, <<7, pin, 0, 0>>)

    # Firmware waits for 50 ms to read sensor
    Process.sleep(60)

    <<_, distance::big-integer-size(16)>> = @i2c.read(pid, 3)
    distance
  end

end

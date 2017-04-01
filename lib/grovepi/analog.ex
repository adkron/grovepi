defmodule GrovePi.Analog do
  @moduledoc ~S"""
  Perform analog I/O using the GrovePi. Analog reads return 10-bit values
  (0-1023) from analog to digital converters on the GrovePi. These values
  map to voltages between 0 and 5 volts. Analog writes generate a steady
  square wave on supported pins (also called PWM). The connectors and pins
  on the GrovePi and GrovePiZero boards differ in their support for analog
  reads and writes.

  When in doubt, consult the following diagram or the corresponding one for
  the GrovePiZero:

  ![GrovePi+](assets/images/GrovePiGraphicalDatasheet.jpg)

  Analog reads can be performed on pins A0, A1, A2, and A3. For most Grove
  analog sensors, the proper pin to use is the one labeled on the port.

  Analog writes only work on the PWM pins. E.g., pins 3, 5, 6, and 9. Just
  like the reads, for most Grove sensors, the proper pin to use is the same
  as the one labeled on the port.

  Example use:

  ```
  iex> {:ok, pid}=GrovePi.start_link
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Analog.read(pid, 0)
  971
  iex> GrovePi.Analog.read(pid, 0)
  400
  ```
  """

  @type pin :: integer
  @type adc_level :: 0..1023
  @type pwm :: 0..255

  @doc """
  Read the value from the specified analog pin. This returns a value from
  0-1023 that maps to 0 to 5 volts.
  """
  @spec read(pin) :: adc_level | {:error, term}
  def read(pin) do
    with :ok <- GrovePi.Board.send_request(<<3, pin, 0, 0>>),
         <<_, value::size(16)>> <- GrovePi.Board.get_response(3),
         do: value
  end

  @doc """
  Write an analog value to a pin. The GrovePi maps the specified value
  (0-255) to a duty cycle for a 1.024 ms square wave (~976 Hz). This
  can be used to dim an LED, for example, by turning the output on only
  a fraction of the time.
  """
  @spec write(pin, pwm) :: :ok | {:error, term}
  def write(pin, value) do
    GrovePi.Board.send_request(<<4, pin, value, 0>>)
  end

end

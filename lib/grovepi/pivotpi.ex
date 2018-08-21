defmodule GrovePi.PivotPi do
  @moduledoc """
  This module lets you interact with the
  [PivotPi](https://www.dexterindustries.com/pivotpi-tutorials-documentation/)
  through the [GrovePi](https://www.dexterindustries.com/grovepi/).

  Plug your PivotPi into the GrovePi I2C-1 port.  Plug your servo motor into
  channel 1. You must initialize the PivotPi board using
  `GrovePi.PivotPi.initialize/0`.

  ```elixir
  iex> GrovePi.PivotPi.start()
  :ok
  iex> GrovePi.PivotPi.angle(1, 180)
  :ok
  iex> GrovePi.PivotPi.angle(1, 90)
  :ok
  iex> GrovePi.PivotPi.angle(1, 0)
  :ok
  iex> GrovePi.PivotPi.led(1, 100)
  :ok
  iex> GrovePi.PivotPi.led(1, 50)
  :ok
  iex> GrovePi.PivotPi.led(1, 0)
  :ok
  ```
  """

  @type channel :: 1..8
  @type angle :: 0..180
  @type percent :: 0..100

  alias GrovePi.PivotPi.PCA9685

  @max_12_bit_value 4095

  @doc """
  Move the Servo motor to a new position.  Accepts angle from 0-180.
  """
  @spec angle(channel, angle) :: :ok | {:error, term}
  def angle(channel, angle) do
    pwm_to_send = @max_12_bit_value - translate_to_servo_range(angle)
    device_channel = channel - 1
    PCA9685.set_pwm(device_channel, 0, pwm_to_send)
  end

  defp translate_to_servo_range(angle_value) do
    value_scaled = angle_value / 180
    round(150 + value_scaled * 450)
  end

  @doc """
  Control the PivotPi LEDs.  Channel # should match Servo #.  Accepts % from 0-100.
  """
  @spec led(channel, percent) :: :ok | {:error, term}
  def led(channel, percent) do
    pwm_to_send = translate_to_12_bit(percent)
    PCA9685.set_pwm(convert_to_led(channel), 0, pwm_to_send)
  end

  defp translate_to_12_bit(percent) do
    round(percent / 100 * @max_12_bit_value)
  end

  defp convert_to_led(channel) do
    channel + 7
  end

  @doc """
  Initialize the PivotPi board.
  """
  @spec initialize() :: :ok | {:error, term}
  def initialize() do
    PCA9685.initialize()
  end
end

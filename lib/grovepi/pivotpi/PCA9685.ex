defmodule GrovePi.PivotPi.PCA9685 do
  alias GrovePi.Board
  use Bitwise

  @moduledoc """
  This module provides lower level functions to interact with the
  [PivotPi](https://www.dexterindustries.com/pivotpi-tutorials-documentation/)
  through the [GrovePi](https://www.dexterindustries.com/grovepi/).  Most users
  should be able to obtain all needed functionality with `GrovePi.PivotPi`.
  """

  # References
  # https://github.com/DexterInd/PivotPi/tree/master/Software/Python
  # https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf

  @type channel :: 0..15

  # registers/etc:
  @pca9685_address     0x40
  @mode1               0x00
  @mode2               0x01
  @prescale            0xfe
  @led0_on_l           0x06
  # @led0_on_h           0x07
  # @led0_off_l          0x08
  # @led0_off_h          0x09
  @all_led_on_l        0xfa
  # @all_led_on_h        0xfb
  # @all_led_off_l       0xfc
  # @all_led_off_h       0xfd

  # mode1 options:
  # @mode1_allcall       0x01 # Unused
  # @mode1_subadr1       0x02 # Unused
  # @mode1_subadr2       0x03 # Unused
  # @mode1_subadr3       0x04 # Unused
  @mode1_sleep           0x10
  @mode1_ai              0x20
  # @mode1_extclk        0x40 # Unused
  # @mode1_restart       0x80 # Unused
  @mode1_default         @mode1_ai

  # mode2 options:
  @mode2_outdrv          0x04  # Totem pole drive
  @mode2_invrt           0x10  # Inverted signal
  @mode2_default         @mode2_outdrv ||| @mode2_invrt

  @default_freq        60

  @doc false
  def initialize() do
    set_pwm_off(:all)
    set_modes()
    set_pwm_freq(@default_freq)
  end

  defp set_modes() do
    # Initialize the mode registers, but don't wake
    # the PCA9685 up yet.
    send_cmd(<<@mode1, @mode1_default ||| @mode1_sleep>>)
    send_cmd(<<@mode2, @mode2_default>>)
  end

  defp set_pwm_freq(freq_hz) do
    # The prescale register can only be set when the
    # PCA9685 is in sleep mode.
    send_cmd(<<@mode1, @mode1_default ||| @mode1_sleep>>)
    send_cmd(<<@prescale, frequency_to_prescale(freq_hz)>>)
    send_cmd(<<@mode1, @mode1_default>>)

    # Wait 500 uS for oscillators to start
    Process.sleep(1)
  end

  @doc """
  Update the PWM on and off times on the specified channel
  or `:all` to write to update all channels.
  """
  @spec set_pwm(channel | :all, integer, integer) :: :ok | {:error, term}
  def set_pwm(channel, on, off) do
    send_cmd(<<channel_to_register(channel),
               on::little-size(16),
               off::little-size(16)>>)
  end

  @doc """
  Turn the specified channel or `:all` ON.
  """
  @spec set_pwm_on(channel | :all) :: :ok | {:error, term}
  def set_pwm_on(channel) do
    set_pwm(channel, 0x1000, 0)
  end

  @doc """
  Turn the specified channel or `:all` OFF.
  """
  @spec set_pwm_off(channel | :all) :: :ok | {:error, term}
  def set_pwm_off(channel) do
    set_pwm(channel, 0, 0x1000)
  end

  defp channel_to_register(channel) when is_integer(channel), do: @led0_on_l + 4 * channel
  defp channel_to_register(:all), do: @all_led_on_l

  defp frequency_to_prescale(hz), do: round(((25000000.0 / 4096.0) / hz) - 1.0)

  @spec send_cmd(binary) :: :ok | {:error, term}
  def send_cmd(command) do
    Board.i2c_write_device(@pca9685_address, command)
  end
end

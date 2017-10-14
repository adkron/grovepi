defmodule GrovePi.PivotPi.PCA9685 do
  @moduledoc false

  # References
  # https://github.com/DexterInd/PivotPi/tree/master/Software/Python
  # https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf

  # registers/etc:
  @pca9685_address     0x40
  @mode1               0x00
  @mode2               0x01
  @prescale            0xfe
  @led0_on_l           0x06
  @led0_on_h           0x07
  @led0_off_l          0x08
  @led0_off_h          0x09
  @all_led_on_l        0xfa
  @all_led_on_h        0xfb
  @all_led_off_l       0xfc
  @all_led_off_h       0xfd

  # mode1 options:
  # @allcall             0x01 # Unused
  # @subadr1             0x02 # Unused
  # @subadr2             0x03 # Unused
  # @subadr3             0x04 # Unused
  @sleep               0x10
  # @restart             0x80 # Unused
  @default_mode1       0x01

  # mode2 options:
  @outdrv              0x04
  @invrt               0x10

  @default_freq        60

  alias GrovePi.{Board}
  import Bitwise

  def start() do
    set_all_pwm(0, 0)
    set_initial_config()
    set_pwm_freq(@default_freq)
  end

  defp set_initial_config() do
    send_cmd(<<@mode2, (@outdrv ||| @invrt)>>) # Totem pole drive, and inverted signal.
    send_cmd(<<@mode1, @default_mode1>>)
    Process.sleep(1) # Wait for oscillator after wake
  end

  defp set_pwm_freq(freq_hz) do
    prescale_val = round(((25000000.0 / 4096.0) / freq_hz) - 1.0)
    sleep_mode = @default_mode1 ||| @sleep
    send_cmd(<<@mode1, sleep_mode>>)
    send_cmd(<<@prescale, prescale_val>>)
    send_cmd(<<@mode1, @default_mode1>>)
    Process.sleep(1) # Wait for oscillator after wake
  end

  def set_pwm(channel, on, off) do
    send_cmd(<<led_on_l_register(channel), calc_8_LSBs(on)>>)
    send_cmd(<<led_on_h_register(channel), calc_4_MSBs(on)>>)
    send_cmd(<<led_off_l_register(channel), calc_8_LSBs(off)>>)
    send_cmd(<<led_off_h_register(channel), calc_4_MSBs(off)>>)
  end

  defp led_on_l_register(channel), do: @led0_on_l + adj_register(channel)

  defp led_on_h_register(channel), do: @led0_on_h + adj_register(channel)

  defp led_off_l_register(channel), do: @led0_off_l + adj_register(channel)

  defp led_off_h_register(channel), do: @led0_off_h + adj_register(channel)

  defp adj_register(channel), do: channel * 4

  def set_all_pwm(on, off) do
    send_cmd(<<@all_led_on_l, calc_8_LSBs(on)>>)
    send_cmd(<<@all_led_on_h, calc_4_MSBs(on)>>)
    send_cmd(<<@all_led_off_l, calc_8_LSBs(off)>>)
    send_cmd(<<@all_led_off_h, calc_4_MSBs(off)>>)
  end

  defp calc_8_LSBs(value), do: value &&& 0xFF

  defp calc_4_MSBs(value), do: value >>> 8

  def send_cmd(command) do
    Board.i2c_write_device(@pca9685_address, command)
  end
end

defmodule GrovePi.RGBLCD do
  @moduledoc """
  """
  use Bitwise

  @rgb_address  0x62
  @text_address 0x3e

  @lcd_cmd_clear 0x01
  @lcd_cmd_home  0x02

  # Display control
  @lcd_cmd_dc    0x08
  @lcd_cmd_dc_display_on    0x04
  @lcd_cmd_dc_cursor_on     0x02
  @lcd_cmd_dc_cursor_blink  0x01

  # Function set
  @lcd_cmd_fs    0x20
  @lcd_cmd_fs_4bit          0x00
  @lcd_cmd_fs_8bit          0x10
  @lcd_cmd_fs_1line         0x00
  @lcd_cmd_fs_2line         0x08
  @lcd_cmd_fs_5x8font       0x00
  @lcd_cmd_fs_5x10font      0x04

  alias GrovePi.Board

  # Currently this is directly translated from Python
  # NOTE: Review datasheet, since this does not seem like
  #       the most efficient way of updating the display.

  def set_rgb(r, g, b) do
    Board.i2c_write_device(@rgb_address, <<0, 0>>)
    Board.i2c_write_device(@rgb_address, <<1, 0>>)
    Board.i2c_write_device(@rgb_address, <<8, 0xaa>>)
    Board.i2c_write_device(@rgb_address, <<4, r>>)
    Board.i2c_write_device(@rgb_address, <<3, g>>)
    Board.i2c_write_device(@rgb_address, <<2, b>>)
  end

  def init() do
    send_text_cmd(@lcd_cmd_clear)
    Process.sleep(50)
    send_text_cmd(@lcd_cmd_fs ||| @lcd_cmd_fs_2line ||| @lcd_cmd_fs_8bit ||| @lcd_cmd_fs_5x8font)
    Process.sleep(50)
    send_text_cmd(@lcd_cmd_dc ||| @lcd_cmd_dc_display_on)
  end

  def set_text(text) do
    send_text_cmd(@lcd_cmd_clear)
    send_chars(text)
  end

  defp send_chars(<<>>), do: :ok
  defp send_chars(<<?\n, rest::binary>>) do
    send_text_cmd(0xc0)
    send_chars(rest)
  end
  defp send_chars(<<c, rest::binary>>) do
    Board.i2c_write_device(@text_address, <<0x40, c>>)
    send_chars(rest)
  end

  defp send_text_cmd(cmd) do
    Board.i2c_write_device(@text_address, <<0x80, cmd>>)
  end
end

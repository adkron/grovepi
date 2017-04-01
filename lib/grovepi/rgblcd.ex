defmodule GrovePi.RGBLCD do
  @moduledoc """
  """

  @rgb_address  0x62
  @text_address 0x3e

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

  def set_text(text) do
    send_text_cmd(0x01) # clear display
    Process.sleep(50)
    send_text_cmd(0x0c)
    send_text_cmd(0x28)
    Process.sleep(50)
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

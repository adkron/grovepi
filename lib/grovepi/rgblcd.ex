defmodule GrovePi.RGBLCD do
  @moduledoc """
  """

  @rgb_address  0x62
  @text_address 0x3e
  @i2c Application.get_env(:grovepi, :i2c)

  # Currently this is directly translated from Python
  # NOTE: Review datasheet, since this does not seem like
  #       the most efficient way of updating the display.

  def set_rgb(pid, r, g, b) do
    @i2c.write_device(pid, @rgb_address, <<0, 0>>)
    @i2c.write_device(pid, @rgb_address, <<1, 0>>)
    @i2c.write_device(pid, @rgb_address, <<8, 0xaa>>)
    @i2c.write_device(pid, @rgb_address, <<4, r>>)
    @i2c.write_device(pid, @rgb_address, <<3, g>>)
    @i2c.write_device(pid, @rgb_address, <<2, b>>)
  end

  def set_text(pid, text) do
    send_text_cmd(pid, 0x01) # clear display
    Process.sleep(50)
    send_text_cmd(pid, 0x0c)
    send_text_cmd(pid, 0x28)
    Process.sleep(50)
    send_chars(pid, text)
  end

  defp send_chars(_pid, <<>>), do: :ok
  defp send_chars(pid, <<?\n, rest::binary>>) do
    send_text_cmd(pid, 0xc0)
    send_chars(pid, rest)
  end
  defp send_chars(pid, <<c, rest::binary>>) do
    @i2c.write_device(pid, @text_address, <<0x40, c>>)
    send_chars(pid, rest)
  end

  defp send_text_cmd(pid, cmd) do
    @i2c.write_device(pid, @text_address, <<0x80, cmd>>)
  end
end

defmodule GrovePi.BuzzerTest do
  use ComponentTestCase, async: true
  @on 1
  @off 0

  setup %{prefix: prefix} = tags do
    {:ok, _} = GrovePi.Buzzer.start_link(@pin, prefix: prefix)
    {:ok, tags}
  end

  test "buzzes for one second by default",
    %{prefix: prefix, board: board} do
    GrovePi.Buzzer.buzz(@pin, prefix)
    Process.sleep 1050
    {off_time, _, <<2, @pin, @off, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)
    {on_time, _, <<2, @pin, @on, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)

    assert_in_delta (off_time - on_time), 1000, 10
  end

  test "buzzes for time specified",
    %{prefix: prefix, board: board} do
    interval = 1
    GrovePi.Buzzer.buzz(@pin, interval, prefix)
    Process.sleep interval + 50
    {off_time, _, <<2, @pin, @off, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)
    {on_time, _, <<2, @pin, @on, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)

    assert_in_delta (off_time - on_time), interval, 10
  end
end

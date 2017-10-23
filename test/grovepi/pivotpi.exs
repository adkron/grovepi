defmodule GrovePi.PivotPiTest do
  use ExUnit.Case, async: true

  setup do
    board = GrovePi.Board.i2c_name(Default)
    start_supervised({GrovePi.I2C, ["i2c-1", "address", name: board]})
    %{board: board}
  end

  test "sets angle for a channel", %{board: board} do
    channel = 10
    angle = 90

    GrovePi.PivotPi.angle(channel, angle)

    assert <<42, 0, 0, 136, 14>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "sets led value for a channel", %{board: board} do
    channel = 10
    led_percent = 50

    GrovePi.PivotPi.led(channel, led_percent)

    assert <<74, 0, 0, 0, 8>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "sends initialization commands", %{board: board} do
    GrovePi.PivotPi.start()

    data =
      board
      |> GrovePi.I2C.get_all_writes
      |> Enum.map(&(&1.data))

    assert data == [
      <<0xfa, 0, 0, 0, 16>>,
      <<0x00, 0x30>>,
      <<0x01, 0x14>>,
      <<0x00, 0x30>>,
      <<0xfe, 0x65>>,
      <<0x00, 0x20>>
    ]
  end
end


defmodule GrovePi.RelayTest do
  use ExUnit.Case, async: true

  alias GrovePi.Relay

  setup do
    board = GrovePi.Board.i2c_name(Default)
    start_supervised({GrovePi.I2C, ["i2c-1", 0x04, name: board]})
    relay_pin = 5
    %{board: board, pin: relay_pin}
  end

  test "off/1 writes 0 to device to turn off", %{board: board, pin: pin} do
    Relay.off(pin)

    assert <<2, pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "on/1 writes 1 to device to turn on", %{board: board, pin: pin} do
    Relay.on(pin)

    assert <<2, pin, 1, 0>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "initialize/1 sets pin mode to output", %{board: board, pin: pin} do
    Relay.initialize(pin)

    assert <<5, pin, 1, 0>> == GrovePi.I2C.get_last_write_data(board)
  end
end

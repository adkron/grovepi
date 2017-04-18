defmodule GrovePi.DigitalTest do
  use ComponentTestCase, async: true
  @input 0
  @output 1

  test "set_pin_mode to input",
  %{prefix: prefix, board: board} do
    GrovePi.Digital.set_pin_mode(prefix, @pin, :input)

    assert <<5, @pin, @input, 0>> == GrovePi.I2C.get_last_write(board)
  end

  test "set_pin_mode to output",
  %{prefix: prefix, board: board} do
    GrovePi.Digital.set_pin_mode(prefix, @pin, :output)

    assert <<5, @pin, @output, 0>> == GrovePi.I2C.get_last_write(board)
  end

  test "set_pin_mode to unsupported mode",
  %{prefix: prefix} do
    assert_raise FunctionClauseError, fn ->
      GrovePi.Digital.set_pin_mode(prefix, @pin, :unsupported)
    end
  end

  test "read requests a response and then reads a bit",
  %{prefix: prefix, board: board} do
    byte_value = Enum.random([0,1])
    GrovePi.I2C.add_response(board, <<byte_value>>)

    assert GrovePi.Digital.read(prefix, @pin) == byte_value

    assert <<1, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)
  end

  test "write writes a single bit",
  %{prefix: prefix, board: board} do
    GrovePi.Digital.write(prefix, @pin, 0)

    assert <<2, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)

    GrovePi.Digital.write(prefix, @pin, 1)
    assert <<2, @pin, 1, 0>> == GrovePi.I2C.get_last_write(board)

    assert_raise  FunctionClauseError, fn ->
      GrovePi.Digital.write(prefix, @pin, 2)
    end
  end
end

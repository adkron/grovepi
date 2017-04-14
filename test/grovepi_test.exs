defmodule GrovePi.GrovePiTest do
  use ExUnit.Case, async: true

  setup do
    prefix = String.to_atom(Time.to_string(Time.utc_now))
    board = GrovePi.Board.i2c_name(prefix)

    GrovePi.Board.start_link(0x40, prefix)
    GrovePi.I2C.reset(board)
    {:ok, [prefix: prefix, board: board]}
  end

  test "getting version works",
    %{prefix: prefix, board: board} do
    GrovePi.I2C.add_response(board, <<0, 1, 2, 3>>)

    assert GrovePi.Board.firmware_version(prefix) == "1.2.3"
    assert GrovePi.I2C.get_last_write(board) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(board) == :no_more_messages
  end

  test "getting version retries with I2C error",
    %{prefix: prefix, board: board} do
    GrovePi.I2C.add_response(board, {:error, :i2c_write_failed})
    GrovePi.I2C.add_response(board, <<0, 1, 2, 3>>)

    assert GrovePi.Board.firmware_version(prefix) == "1.2.3"
    assert GrovePi.I2C.get_last_write(board) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(board) == :no_more_messages
  end
end

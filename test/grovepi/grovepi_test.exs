defmodule GrovePi.GrovePiTest do
  use ComponentTestCase, async: true

  test "getting version works", %{prefix: prefix, board: board} do
    GrovePi.I2C.add_response(board, <<0, 1, 2, 3>>)

    assert GrovePi.Board.firmware_version(prefix) == "1.2.3"
    assert GrovePi.I2C.get_last_write_data(board) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(board) == {:error, :no_more_messages}
  end
end

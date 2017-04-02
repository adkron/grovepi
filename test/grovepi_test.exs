defmodule GrovePi.GrovePiTest do
  use ExUnit.Case

  setup do
    GrovePi.I2C.reset(GrovePi.Board)
    {:ok, []}
  end

  test "getting version works" do
    GrovePi.I2C.add_response(GrovePi.Board, <<0, 1, 2, 3>>)

    assert GrovePi.Board.firmware_version() == "1.2.3"
    assert GrovePi.I2C.get_last_write(GrovePi.Board) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(GrovePi.Board) == :no_more_messages
  end

  test "getting version retries with I2C error" do
    GrovePi.I2C.add_response(GrovePi.Board, {:error, :i2c_write_failed})
    GrovePi.I2C.add_response(GrovePi.Board, <<0, 1, 2, 3>>)

    assert GrovePi.Board.firmware_version() == "1.2.3"
    assert GrovePi.I2C.get_last_write(GrovePi.Board) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(GrovePi.Board) == :no_more_messages
  end
end

defmodule GrovePi.DHTTest do
  use ComponentTestCase, async: true

  setup %{prefix: prefix} = tags do
    {:ok, _} = GrovePi.DHT.start_link(@pin, prefix: prefix)
    {:ok, tags}
  end

  test "gets temp and humidity",
    %{prefix: prefix, board: board} do
    temp = 20.0
    humidity = 10.0

    GrovePi.I2C.add_response(board, <<1, temp::little-float-size(32), humidity::little-float-size(32)>>)

    assert {temp, humidity} == GrovePi.DHT.read_temp_and_humidity(@pin, prefix)
    assert <<40, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)
  end
end

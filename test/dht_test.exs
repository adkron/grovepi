defmodule GrovePi.DHTTest do
  use ExUnit.Case
  @pin 5

  setup do
    {:ok, _} = GrovePi.DHT.start_link(@pin)

    GrovePi.I2C.reset(GrovePi.Board)

    :ok
  end

  test "gets temp and humidity" do
    temp = 20.0
    humidity = 10.0

    GrovePi.I2C.add_response(GrovePi.Board, <<1, temp::little-float-size(32), humidity::little-float-size(32)>>)

    assert {temp, humidity} == GrovePi.DHT.read_temp_and_humidity(@pin)
    assert <<40, @pin, 0, 0>> == GrovePi.I2C.get_last_write(GrovePi.Board)
  end
end

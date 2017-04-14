defmodule GrovePi.DHTTest do
  use ExUnit.Case, async: true
  @pin 5
  @prefix __MODULE__
  @board GrovePi.Board.i2c_name(__MODULE__)

  def start_dht() do
    with {:ok, _} <- GrovePi.Supervisor.start_link(0x40, @prefix),
         {:ok, _} = GrovePi.DHT.start_link(@pin, prefix: @prefix),
    do: :ok
  end

  setup do
    start_dht()

    GrovePi.I2C.reset(@board)

    :ok
  end

  test "gets temp and humidity" do
    temp = 20.0
    humidity = 10.0

    GrovePi.I2C.add_response(@board, <<1, temp::little-float-size(32), humidity::little-float-size(32)>>)

    assert {temp, humidity} == GrovePi.DHT.read_temp_and_humidity(@pin, @prefix)
    assert <<40, @pin, 0, 0>> == GrovePi.I2C.get_last_write(@board)
  end
end

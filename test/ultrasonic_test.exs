defmodule GrovePi.UltrasonicTest do
  use ExUnit.Case
  @pin 5

  setup do
    {:ok, _} = GrovePi.Ultrasonic.start_link(@pin)

    GrovePi.I2C.reset(GrovePi.Board)

    :ok
  end

  test "gets distance" do
    distance = 20

    GrovePi.I2C.add_response(GrovePi.Board, <<1, distance::big-integer-size(16)>>)

    Process.sleep(61)

    assert distance == GrovePi.Ultrasonic.read_distance(@pin)
    assert <<7, @pin, 0, 0>> == GrovePi.I2C.get_last_write(GrovePi.Board)
  end
end

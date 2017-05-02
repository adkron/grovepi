defmodule GrovePi.UltrasonicTest do
  use ComponentTestCase, async: true

  setup %{prefix: prefix} = tags do
    {:ok, _} = GrovePi.Ultrasonic.start_link(@pin, prefix: prefix)
    {:ok, tags}
  end

  test "gets distance",
    %{prefix: prefix, board: board} do
    distance = 20

    GrovePi.I2C.add_response(board, <<1, distance::big-integer-size(16)>>)

    assert distance == GrovePi.Ultrasonic.read_distance(@pin, prefix)

    {_, last_message_content} = GrovePi.I2C.get_last_write(board)
    assert last_message_content == <<7, @pin, 0, 0>>
  end
end

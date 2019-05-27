defmodule GrovePi.UltrasonicTest do
  use ComponentTestCase, async: true

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} =
      GrovePi.Ultrasonic.start_link(
        @pin,
        poll_interval: poll_interval,
        prefix: prefix
      )

    {:ok, tags}
  end

  test "gets distance with read/2", %{prefix: prefix, board: board} do
    distance = 20

    GrovePi.I2C.add_response(board, <<1, distance::big-integer-size(16)>>)

    assert distance == GrovePi.Ultrasonic.read(@pin, prefix)
    assert <<7, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end

  @tag :capture_log
  test "receives message after subscribe", %{prefix: prefix, board: board} do
    GrovePi.Ultrasonic.subscribe(@pin, :changed, prefix)

    GrovePi.I2C.add_responses(board, [
      10,
      20
    ])

    assert_receive {@pin, :changed, _}, 300
  end
end

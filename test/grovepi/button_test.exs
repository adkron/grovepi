defmodule GrovePi.ButtonTest do
  use ComponentTestCase, async: true
  @pressed <<1>>
  @released <<0>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} =
      GrovePi.Button.start_link(
        @pin,
        poll_interval: poll_interval,
        prefix: prefix
      )

    {:ok, tags}
  end

  @tag :capture_log
  test "receives message after subscribe", %{prefix: prefix, board: board} do
    GrovePi.Button.subscribe(@pin, :released, prefix)

    GrovePi.I2C.add_responses(board, [
      @pressed,
      @released
    ])

    assert_receive {@pin, :released, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading gets from the grovepi board", %{prefix: prefix, board: board} do
    GrovePi.I2C.add_responses(board, [@pressed, @released])

    assert GrovePi.Button.read(@pin, prefix) == 1

    assert <<1, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)

    assert GrovePi.Button.read(@pin, prefix) == 0

    assert <<1, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end
end

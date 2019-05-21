defmodule GrovePi.IRReflectiveTest do
  use ComponentTestCase, async: true
  @far <<1>>
  @close <<0>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} =
      GrovePi.IRReflective.start_link(
        @pin,
        poll_interval: poll_interval,
        prefix: prefix
      )

    {:ok, tags}
  end

  @tag :capture_log
  test "receives message after subscribe", %{prefix: prefix, board: board} do
    GrovePi.IRReflective.subscribe(@pin, :close, prefix)

    GrovePi.I2C.add_responses(board, [
      @far,
      @close
    ])

    assert_receive {@pin, :close, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading gets from the grovepi board", %{prefix: prefix, board: board} do
    GrovePi.I2C.add_responses(board, [@far, @close])

    assert GrovePi.IRReflective.read(@pin, prefix) == 1

    assert <<1, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)

    assert GrovePi.IRReflective.read(@pin, prefix) == 0

    assert <<1, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end
end

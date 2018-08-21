defmodule GrovePi.PotentiometerTest do
  use ComponentTestCase, async: true
  @read_1 <<1>>
  @read_2 <<120>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} =
      GrovePi.Potentiometer.start_link(
        @pin,
        poll_interval: poll_interval,
        prefix: prefix
      )

    {:ok, tags}
  end

  @tag :capture_log
  test "recovers from I2C error", %{prefix: prefix, board: board} do
    GrovePi.Potentiometer.subscribe(@pin, :changed, prefix)

    GrovePi.I2C.add_responses(board, [
      {:error, :i2c_write_failed},
      @read_1,
      @read_2
    ])

    assert_receive {@pin, :changed, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading gets from the grovepi board", %{prefix: prefix, board: board} do
    GrovePi.I2C.add_responses(board, [@read_1, @read_2])

    assert GrovePi.Potentiometer.read(@pin, prefix) == <<1>>

    assert <<3, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)

    assert GrovePi.Potentiometer.read(@pin, prefix) == <<120>>

    assert <<3, @pin, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end
end

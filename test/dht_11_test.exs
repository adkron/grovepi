defmodule GrovePi.DHT11Test do
  use ComponentTestCase, async: true
  @read_1 <<0, 23.0::little-float-size(32), 44.5::little-float-size(32)>>
  @read_2 <<0, 13.5::little-float-size(32), 77.5::little-float-size(32)>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} = GrovePi.DHT11.start_link(@pin,
                                         poll_interval: poll_interval,
                                         prefix: prefix,
                                       )

      {:ok, tags}
  end

  @tag :capture_log
  test "recovers from I2C error",
  %{prefix: prefix, board: board} do
    GrovePi.DHT11.subscribe(@pin, :changed, prefix)
    GrovePi.I2C.add_responses(board, [
                                {:error, :i2c_write_failed},
                                @read_1,
                                @read_2,
                              ])

    assert_receive {@pin, :changed, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading gets from the grovepi board",
  %{prefix: prefix, board: board} do
    GrovePi.I2C.add_responses(board, [@read_1, @read_2])

    assert GrovePi.DHT11.read(@pin, prefix) == {23.0, 44.5}

    assert <<40, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)

    assert GrovePi.DHT11.read(@pin, prefix) == {13.5, 77.5}

    assert <<40, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)
  end
end

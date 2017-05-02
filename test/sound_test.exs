defmodule GrovePi.SoundTest do
  use ComponentTestCase, async: true
  @exceeded_threshold <<1, 511::size(16)>>
  @under_threshold <<1, 489::size(16)>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} = GrovePi.Sound.start_link(@pin,
                                         poll_interval: poll_interval,
                                         prefix: prefix,
                                       )

      {:ok, tags}
  end

  @tag :capture_log
  test "recovers from I2C error",
  %{prefix: prefix, board: board} do
    GrovePi.Sound.subscribe(@pin, :quiet, prefix)
    GrovePi.I2C.add_responses(board, [
                                {:error, :i2c_write_failed},
                                @exceeded_threshold,
                                @under_threshold,
                              ])

    assert_receive {@pin, :quiet, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading notifies subscribers",
  %{prefix: prefix, board: board} do
    GrovePi.I2C.add_responses(board, [@exceeded_threshold, @under_threshold])

    assert GrovePi.Sound.read(@pin, prefix) == 511

    {_, last_write} = GrovePi.I2C.get_last_write(board)
    assert last_write == <<3, @pin, 0, 0>>

    assert GrovePi.Sound.read(@pin, prefix) == 489

    {_, last_write} = GrovePi.I2C.get_last_write(board)
    assert last_write == <<3, @pin, 0, 0>>
  end
end

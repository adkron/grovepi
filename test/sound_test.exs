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

  test "registering for a loud event receives loud messages",
  %{prefix: prefix, board: board} do
    GrovePi.Sound.subscribe(@pin, :loud, prefix)
    GrovePi.I2C.add_responses(board, [@exceeded_threshold])

    assert_receive {@pin, :loud, _}, 300
  end

  test "registering for a quiet event receives quiet messages",
  %{prefix: prefix, board: board} do
    GrovePi.Sound.subscribe(@pin, :quiet, prefix)
    GrovePi.I2C.add_responses(board, [@under_threshold])

    assert_receive {@pin, :quiet, _}, 300
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
    GrovePi.Sound.subscribe(@pin, :quiet, prefix)
    GrovePi.Sound.subscribe(@pin, :loud, prefix)
    GrovePi.I2C.add_responses(board, [@exceeded_threshold, @under_threshold, @exceeded_threshold])

    GrovePi.Sound.read(@pin, prefix)

    assert_receive {@pin, :loud, _}, 10

    GrovePi.Sound.read(@pin, prefix)

    assert_receive {@pin, :quiet, _}, 10
  end
end

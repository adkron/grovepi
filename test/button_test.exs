defmodule GrovePi.ButtonTest do
  use ComponentTestCase, async: true
  @pressed <<1>>
  @released <<0>>

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, _} = GrovePi.Button.start_link(@pin,
                                         poll_interval: poll_interval,
                                         prefix: prefix,
                                       )

      {:ok, tags}
  end

  test "registering for a pressed event receives pressed messages",
  %{prefix: prefix, board: board} do
    GrovePi.Button.subscribe(@pin, :pressed, prefix)
    GrovePi.I2C.add_responses(board, [@pressed])

    assert_receive {@pin, :pressed, _}, 300
  end

  test "registering for a released event receives released messages",
  %{prefix: prefix, board: board} do
    GrovePi.Button.subscribe(@pin, :released, prefix)
    GrovePi.I2C.add_responses(board, [@pressed, @released])

    assert_receive {@pin, :released, _}, 300
  end

  @tag :capture_log
  test "recovers from I2C error",
  %{prefix: prefix, board: board} do
    GrovePi.Button.subscribe(@pin, :released, prefix)
    GrovePi.I2C.add_responses(board, [
                                {:error, :i2c_write_failed},
                                @pressed,
                                @released,
                              ])

    assert_receive {@pin, :released, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading notifies subscribers",
  %{prefix: prefix, board: board} do
    GrovePi.Button.subscribe(@pin, :released, prefix)
    GrovePi.Button.subscribe(@pin, :pressed, prefix)
    GrovePi.I2C.add_responses(board, [@pressed, @released, @pressed])

    GrovePi.Button.read(@pin, prefix)

    assert_receive {@pin, :pressed, _}, 10

    GrovePi.Button.read(@pin, prefix)

    assert_receive {@pin, :released, _}, 10
  end
end

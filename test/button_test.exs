defmodule GrovePi.ButtonTest do
  use ExUnit.Case, async: true
  @pressed <<1>>
  @released <<0>>
  @pin 5
  @moduletag report: [:prefix, :board, :poll_interval]

  def start_button(prefix, poll_interval) do
    with {:ok, _} <- GrovePi.Supervisor.start_link(0x40, prefix),
         {:ok, _} <- GrovePi.Button.start_link(@pin,
                                          poll_interval: poll_interval,
                                          prefix: prefix,
                                        ),
    do: :ok
  end

  describe "default button" do
    setup tags do
      prefix = String.to_atom(Time.to_string(Time.utc_now))
      board = GrovePi.Board.i2c_name(prefix)
      poll_interval = Map.get(tags, :poll_interval, 1)

      start_button(prefix, poll_interval)

      GrovePi.I2C.reset(board)

      {:ok, [prefix: prefix, board: board]}
    end

    test "registering for a pressed event receives pressed messages",
      %{prefix: prefix, board: board} do
      GrovePi.Button.subscribe(@pin, :pressed, prefix)
      GrovePi.I2C.add_responses(board, [@pressed])

      assert_receive {@pin, :pressed}, 300
    end

    test "registering for a released event receives released messages",
      %{prefix: prefix, board: board} do
      GrovePi.Button.subscribe(@pin, :released, prefix)
      GrovePi.I2C.add_responses(board, [@pressed, @released])

      assert_receive {@pin, :released}, 300
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

      assert_receive {@pin, :released}, 300
    end

    @tag poll_interval: 1000000
    test "reading notifies subscribers",
      %{prefix: prefix, board: board} do
      GrovePi.Button.subscribe(@pin, :released, prefix)
      GrovePi.Button.subscribe(@pin, :pressed, prefix)
      GrovePi.I2C.add_responses(board, [@pressed, @released, @pressed])

      GrovePi.Button.read(@pin, prefix)

      assert_receive {@pin, :pressed}, 10

      GrovePi.Button.read(@pin, prefix)

      assert_receive {@pin, :released}, 10
    end
  end
end

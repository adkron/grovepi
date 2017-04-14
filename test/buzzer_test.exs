defmodule GrovePi.BuzzerTest do
  use ExUnit.Case, async: true
  @on 1
  @off 0
  @pin 5
  @moduletag report: [:prefix, :board]

  def start_buzzer(prefix) do
    with {:ok, _} <- GrovePi.Supervisor.start_link(0x40, prefix),
         {:ok, _} = GrovePi.Buzzer.start_link(@pin, prefix: prefix),
    do: :ok
  end

  setup do
    prefix = String.to_atom(Time.to_string(Time.utc_now))
    board = GrovePi.Board.i2c_name(prefix)

    start_buzzer(prefix)

    GrovePi.I2C.reset(board)

    {:ok, [prefix: prefix, board: board]}
  end

  test "buzzes for one second by default",
    %{prefix: prefix, board: board} do
    GrovePi.Buzzer.buzz(@pin, prefix)
    Process.sleep 1010
    {off_time, <<2, @pin, @off, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)
    {on_time, <<2, @pin, @on, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)

    assert_in_delta (off_time - on_time), 1000, 10
  end

  test "buzzes for time specified",
    %{prefix: prefix, board: board} do
    interval = 1
    GrovePi.Buzzer.buzz(@pin, interval, prefix)
    Process.sleep interval + 10
    {off_time, <<2, @pin, @off, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)
    {on_time, <<2, @pin, @on, 0>>} = GrovePi.I2C.get_last_write(board, include_time: true)

    assert_in_delta (off_time - on_time), interval, 10
  end
end

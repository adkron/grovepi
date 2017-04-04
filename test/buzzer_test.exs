defmodule GrovePi.BuzzerTest do
  use ExUnit.Case
  @on 1
  @off 0

  setup do
    pin = 5
    {:ok, _} = GrovePi.Buzzer.start_link(pin)

    GrovePi.I2C.reset(GrovePi.Board)

    {:ok, [pin: pin]}
  end

  test "buzzes for one second by default",
  %{pin: pin} do
    GrovePi.Buzzer.buzz(pin)
    Process.sleep 1100
    {off_time, <<2, ^pin, @off, 0>>} = GrovePi.I2C.get_last_write(GrovePi.Board, include_time: true)
    {on_time, <<2, ^pin, @on, 0>>} = GrovePi.I2C.get_last_write(GrovePi.Board, include_time: true)

    assert_in_delta (off_time - on_time), 1000, 10
  end

  test "buzzes for time specified",
  %{pin: pin} do
    interval = 100
    GrovePi.Buzzer.buzz(pin, interval)
    Process.sleep interval + 10
    {off_time, <<2, ^pin, @off, 0>>} = GrovePi.I2C.get_last_write(GrovePi.Board, include_time: true)
    {on_time, <<2, ^pin, @on, 0>>} = GrovePi.I2C.get_last_write(GrovePi.Board, include_time: true)

    assert_in_delta (off_time - on_time), interval, 10
  end
end

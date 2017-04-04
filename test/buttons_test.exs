defmodule GrovePi.ButtonsTest do
  use ExUnit.Case
  @pressed <<1>>
  @released <<0>>
  @pin 5

  setup do
    {:ok, _} = GrovePi.Button.start_link(@pin)

    GrovePi.I2C.reset(GrovePi.Board)

    :ok
  end

  test "registering for a pressed event receives pressed messages" do
    GrovePi.Button.subscribe(@pin, :pressed)
    GrovePi.I2C.add_response(GrovePi.Board, @pressed)

    assert_receive {@pin, :pressed}, 300
  end

  test "registering for a released event receives released messages" do
    GrovePi.Button.subscribe(@pin, :released)
    GrovePi.I2C.add_responses(GrovePi.Board, [@pressed, @released])

    assert_receive {@pin, :released}, 300
  end

  @tag :capture_log
  test "recovers from I2C error" do
    GrovePi.Button.subscribe(@pin, :released)
    GrovePi.I2C.add_responses(GrovePi.Board, [
                                {:error, :i2c_write_failed},
                                @pressed,
                                @released,
                              ])

    Process.sleep 100

    assert_receive {@pin, :released}, 300
  end
end

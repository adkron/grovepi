defmodule GrovePi.ButtonsTest do
  use ExUnit.Case, async: true
  @pressed <<1>>
  @released <<0>>

  setup do
    Process.sleep 100
    pin = 5
    {:ok, _} = GrovePi.Button.start_link(pin)

    {:ok, [pin: pin]}
  end

  test "registering for a pressed event receives pressed messages",
  %{pin: pin} do
    GrovePi.Button.subscribe(pin, :pressed)
    GrovePi.I2C.add_response(GrovePi.Board, @pressed)

    assert_receive {^pin, :pressed}, 300
  end

  test "registering for a released event receives released messages",
  %{pin: pin} do
    GrovePi.Button.subscribe(pin, :released)
    GrovePi.I2C.add_responses(GrovePi.Board, [@pressed, @released])

    assert_receive {^pin, :released}, 300
  end

  @tag :capture_log
  test "recovers from I2C error",
  %{pin: pin} do
    GrovePi.Button.subscribe(pin, :released)
    GrovePi.I2C.add_responses(GrovePi.Board, [{:error, :i2c_write_failed}])

    Process.sleep 100

    GrovePi.I2C.add_responses(GrovePi.Board, [@pressed, @released])
    assert_receive {^pin, :released}, 300
  end

  def resend(pid, argument) do
    send(pid, {:called_with, argument})
  end
end

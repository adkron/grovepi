defmodule GrovePi.ButtonsTest do
  use ExUnit.Case, async: true
  @pressed 1
  @released 0

  setup do
    :timer.sleep 100
    {:ok, grove_pid} = GrovePi.start_link
    :ok = GrovePi.Buttons.start_link(grove_pid)

    {:ok, [grove: grove_pid]}
  end

  test "registering for a pressed event receives pressed messages",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.register({:pressed, pin})

    GrovePi.I2C.set_level(grove, @pressed)

    GrovePi.Buttons.notify_change(pin, {0, 1})

    assert_receive {:pressed, pin}
  end

  test "registering for a released event receives released messages",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.register({:released, pin})

    GrovePi.I2C.set_level(grove, @pressed)
    :timer.sleep 100
    GrovePi.I2C.set_level(grove, @released)

    GrovePi.Buttons.notify_change(pin, {1, 0})

    assert_receive {:released, pin}
  end
end

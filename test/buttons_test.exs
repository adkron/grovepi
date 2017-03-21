defmodule GrovePi.ButtonsTest do
  use ExUnit.Case, async: true

  test "registering for a pressed event receives presses" do
    pin = 5
    GrovePi.Buttons.start_link(self)
    GrovePi.Buttons.register({:pressed, pin})

    GrovePi.Buttons.notify_change(pin, {0, 1})

    assert_receive {:pressed, pin}
  end

  test "registering for a released event receives presses" do
    pin = 5
    GrovePi.Buttons.start_link(self)
    GrovePi.Buttons.register({:released, pin})

    GrovePi.Buttons.notify_change(pin, {1, 0})

    assert_receive {:released, pin}
  end
end

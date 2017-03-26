defmodule GrovePi.ButtonsTest do
  use ExUnit.Case, async: true
  @pressed <<1>>
  @released <<0>>

  setup do
    :timer.sleep 100
    {:ok, grove_pid} = GrovePi.start_link
    {:ok, _} = GrovePi.Buttons.start_link(grove_pid)

    {:ok, [grove: grove_pid]}
  end

  test "registering for a pressed event receives pressed messages",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.add(pin)
    GrovePi.Buttons.register({:pressed, pin})
    GrovePi.I2C.add_response(grove, @pressed)

    assert_receive {:pressed, ^pin}, 300
  end

  test "registering for a released event receives released messages",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.add(pin)
    GrovePi.Buttons.register({:released, pin})
    GrovePi.I2C.add_responses(grove, [@pressed, @released])

    assert_receive {:released, ^pin}, 300
  end

  test "recovers from I2C error",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.add(pin)
    GrovePi.Buttons.register({:released, pin})
    GrovePi.I2C.add_responses(grove, [{:error, :i2c_write_failed}])

    Process.sleep 100

    GrovePi.I2C.add_responses(grove, [@pressed, @released])
    assert_receive {:released, ^pin}, 300
  end

  def resend(pid, argument) do
    send(pid, {:called_with, argument})
  end

  test "registering for pressed event with {module, function, arguement}",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.add(pin)
    GrovePi.Buttons.register({:pressed, pin}, {__MODULE__, :resend, ["argument"]})
    GrovePi.I2C.add_response(grove, @pressed)

    assert_receive {:called_with, "argument"}, 300
  end

  test "registering for released event with {module, function, arguement}",
  %{grove: grove} do
    pin = 5
    GrovePi.Buttons.add(pin)
    GrovePi.Buttons.register({:released, pin}, {__MODULE__, :resend, ["argument"]})
    GrovePi.I2C.add_responses(grove, [@pressed, @released])

    assert_receive {:called_with, "argument"}, 300
  end
end

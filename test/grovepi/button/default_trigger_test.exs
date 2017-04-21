defmodule GrovePi.Button.DefaultTriggerTest do
  use ExUnit.Case, async: true
  alias GrovePi.Button.DefaultTrigger
  alias GrovePi.Button.DefaultTrigger.State

  test "initial state is released" do
    assert %State{value: 0} == DefaultTrigger.initial_state
  end

  test "update with same value" do
    released_state = %State{value: 0}
    assert {:ok, released_state} == DefaultTrigger.update(0, released_state)

    pressed_state = %State{value: 1}
    assert {:ok, pressed_state} == DefaultTrigger.update(1, pressed_state)
  end

  test "return pressed event" do
    released_state = %State{value: 0}
    pressed_state = %State{value: 1}

    assert {:pressed, pressed_state} == DefaultTrigger.update(1, released_state)
  end

  test "return released event" do
    released_state = %State{value: 0}
    pressed_state = %State{value: 1}

    assert {:released, released_state} == DefaultTrigger.update(0, pressed_state)
  end
end

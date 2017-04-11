defmodule GrovePi.ButtonTest do
  use ExUnit.Case, async: true
  @pressed <<1>>
  @released <<0>>
  @pin 5

  def start_button(poll_interval \\ 1) do
    with {:ok, _} <- GrovePi.Registry.Pin.start_link(ButtonTest.Pin),
         {:ok, _} <- GrovePi.Registry.Subscriber.start_link(ButtonTest.Subscriber),
         {:ok, _} <- GrovePi.Board.start_link(0x40, name: ButtonTest.Board),
         {:ok, _} <- GrovePi.Button.start_link(@pin,
                                          poll_interval: poll_interval,
                                          pin_registry: ButtonTest.Pin,
                                          subscriber_registry: ButtonTest.Subscriber,
                                          board: ButtonTest.Board,
                                        ),
    do: :ok
  end

  describe "default button" do
    setup do
      start_button()

      GrovePi.I2C.reset(ButtonTest.Board)

      :ok
    end

    test "registering for a pressed event receives pressed messages" do
      GrovePi.Button.subscribe(@pin, :pressed, ButtonTest.Subscriber)
      GrovePi.I2C.add_response(ButtonTest.Board, @pressed)

      assert_receive {@pin, :pressed}, 300
    end

    test "registering for a released event receives released messages" do
      GrovePi.Button.subscribe(@pin, :released, ButtonTest.Subscriber)
      GrovePi.I2C.add_responses(ButtonTest.Board, [@pressed, @released])

      assert_receive {@pin, :released}, 300
    end

    @tag :capture_log
    test "recovers from I2C error" do
      GrovePi.Button.subscribe(@pin, :released, ButtonTest.Subscriber)
      GrovePi.I2C.add_responses(ButtonTest.Board, [
                                  {:error, :i2c_write_failed},
                                  @pressed,
                                  @released,
                                ])

      Process.sleep 10

      assert_receive {@pin, :released}, 300
    end
  end

  test "reading notifies subscribers" do
    start_button(1000000)

    GrovePi.I2C.reset(ButtonTest.Board)
    GrovePi.Button.subscribe(@pin, :released, ButtonTest.Subscriber)
    GrovePi.Button.subscribe(@pin, :pressed, ButtonTest.Subscriber)
    GrovePi.I2C.add_responses(ButtonTest.Board, [@pressed, @released, @pressed])

    GrovePi.Button.read(@pin, ButtonTest.Pin)

    assert_receive {@pin, :pressed}, 10

    GrovePi.Button.read(@pin, ButtonTest.Pin)

    assert_receive {@pin, :released}, 10
  end
end

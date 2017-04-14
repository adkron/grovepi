defmodule GrovePi.ButtonTest do
  use ExUnit.Case, async: true
  @pressed <<1>>
  @released <<0>>
  @pin 5
  @prefix __MODULE__
  @board GrovePi.Board.i2c_name(__MODULE__)

  def start_button(poll_interval \\ 1) do
    Process.sleep 10

    with {:ok, _} <- GrovePi.Supervisor.start_link(0x40, @prefix),
         {:ok, _} <- GrovePi.Button.start_link(@pin,
                                          poll_interval: poll_interval,
                                          prefix: @prefix,
                                        ),
    do: :ok
  end

  describe "default button" do
    setup do
      start_button()

      GrovePi.I2C.reset(@board)

      :ok
    end

    test "registering for a pressed event receives pressed messages" do
      GrovePi.Button.subscribe(@pin, :pressed, @prefix)
      GrovePi.I2C.add_response(@board, @pressed)

      assert_receive {@pin, :pressed}, 300
    end

    test "registering for a released event receives released messages" do
      GrovePi.Button.subscribe(@pin, :released, @prefix)
      GrovePi.I2C.add_responses(@board, [@pressed, @released])

      assert_receive {@pin, :released}, 300
    end

    @tag :capture_log
    test "recovers from I2C error" do
      GrovePi.Button.subscribe(@pin, :released, @prefix)
      GrovePi.I2C.add_responses(@board, [
                                  {:error, :i2c_write_failed},
                                  @pressed,
                                  @released,
                                ])

      assert_receive {@pin, :released}, 300
    end
  end

  test "reading notifies subscribers" do
    start_button(1000000)

    GrovePi.I2C.reset(@board)
    GrovePi.Button.subscribe(@pin, :released, @prefix)
    GrovePi.Button.subscribe(@pin, :pressed, @prefix)
    GrovePi.I2C.add_responses(@board, [@pressed, @released, @pressed])

    GrovePi.Button.read(@pin, @prefix)

    assert_receive {@pin, :pressed}, 10

    GrovePi.Button.read(@pin, @prefix)

    assert_receive {@pin, :released}, 10
  end
end

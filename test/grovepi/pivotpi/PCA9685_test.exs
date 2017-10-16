defmodule GrovePi.PivotPi.PCA9685Test do
    use ExUnit.Case, async: true

    setup do
      board = GrovePi.Board.i2c_name(Default)
      start_supervised({GrovePi.I2C, ["i2c-1", "address", name: board]})
      %{board: board}
    end

    describe "start/0" do
      test "sends initialization commands", %{board: board} do
        GrovePi.PivotPi.PCA9685.start()

        six = GrovePi.I2C.get_last_write(board)
        five = GrovePi.I2C.get_last_write(board)
        four = GrovePi.I2C.get_last_write(board)
        three = GrovePi.I2C.get_last_write(board)
        two = GrovePi.I2C.get_last_write(board)
        one = GrovePi.I2C.get_last_write(board)
        no_message = GrovePi.I2C.get_last_write(board)

        assert one == %{address: 0x40, buffer: <<0xfa, 0, 0, 0, 16>>}
        assert two.buffer == <<0x00, 0x30>>
        assert three.buffer == <<0x01, 0x14>>
        assert four.buffer == <<0x00, 0x30>>
        assert five.buffer == <<0xfe, 101>>
        assert six.buffer == <<0x00, 0x20>>
        assert :no_more_messages == no_message

      end
    end
end

defmodule GrovePi.PivotPi.PCA9685Test do
  use ExUnit.Case, async: true

  setup do
    board = GrovePi.Board.i2c_name(Default)
    start_supervised({GrovePi.I2C, ["i2c-1", "address", name: board]})
    %{board: board}
  end

  test "sends initialization commands", %{board: board} do
    GrovePi.PivotPi.PCA9685.initialize()

    messages = GrovePi.I2C.get_all_writes(board)
    %{address: address} = List.first(messages)
    data = Enum.map(messages, &(&1.data))

    assert address == 0x40
    assert data == [
      <<0xfa, 0, 0, 0, 16>>,
      <<0x00, 0x30>>,
      <<0x01, 0x14>>,
      <<0x00, 0x30>>,
      <<0xfe, 0x65>>,
      <<0x00, 0x20>>
    ]
  end

  test "sets channel pwm values", %{board: board} do
    channel_1 = 1
    on = 0x1000
    off = 0

    GrovePi.PivotPi.PCA9685.set_pwm(channel_1, on, off)

    assert <<10, 0, 16, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "sets channel pwm on", %{board: board} do
    channel_1 = 1

    GrovePi.PivotPi.PCA9685.set_pwm_on(channel_1)

    assert <<10, 0, 16, 0, 0>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "sets channel pwm off", %{board: board} do
    channel_1 = 1

    GrovePi.PivotPi.PCA9685.set_pwm_off(channel_1)

    assert <<10, 0, 0, 0, 16>> == GrovePi.I2C.get_last_write_data(board)
  end

  test "sends command to board", %{board: board} do
    command = <<1, 2, 3>>

    GrovePi.PivotPi.PCA9685.send_cmd(command)
    write = GrovePi.I2C.get_last_write(board)

    assert 0x40 == write.address
    assert <<1, 2, 3>> == write.data
  end
end

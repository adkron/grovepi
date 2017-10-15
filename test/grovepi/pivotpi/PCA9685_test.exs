defmodule GrovePi.PivotPi.PCA9685Test do
  use ExUnit.Case, async: true

  setup do
    board = GrovePi.Board.i2c_name(Default)
    start_supervised({GrovePi.I2C, ["i2c-1", "address", name: board]})
    %{board: board}
  end

  test "sends initialization commands", %{board: board} do
    GrovePi.PivotPi.PCA9685.start()

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
end

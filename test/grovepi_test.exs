defmodule GrovePi.GrovePiTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, grove_pid} = GrovePi.start_link
    {:ok, [grove: grove_pid]}
  end

  test "getting version works",
    %{grove: grove} do
    GrovePi.I2C.add_response(grove, <<0, 1, 2, 3>>)

    assert GrovePi.firmware_version(grove) == "1.2.3"
    assert GrovePi.I2C.get_last_write(grove) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(grove) == :no_more_messages
  end

  test "getting version with I2C error",
    %{grove: grove} do
    GrovePi.I2C.add_response(grove, {:error, :i2c_write_failed})

    # Check that the error is passed through
    assert GrovePi.firmware_version(grove) == {:error, :i2c_write_failed}
    assert GrovePi.I2C.get_last_write(grove) == <<8, 0, 0, 0>>
    assert GrovePi.I2C.get_last_write(grove) == :no_more_messages
  end
end

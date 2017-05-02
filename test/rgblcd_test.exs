defmodule GrovePi.RGBLCDTest do
  use ComponentTestCase, async: true
  alias GrovePi.RGBLCD
  @text_address 0x3e

  setup %{prefix: prefix} = tags do
    {:ok, _} = GrovePi.RGBLCD.start_link(prefix: prefix)
    wait_for_display_initialization()
    {:ok, tags}
  end

  test "clears lcd on initialization",
  %{board: board} do
    expected_clear_message = {@text_address, <<0x80, 0x01>>}
    expected_function_select = {@text_address, <<0x80, 0x38>>}
    expected_display_control = {@text_address, <<0x80, 0x0c>>}

    assert expected_display_control == GrovePi.I2C.get_last_write(board)
    assert expected_function_select == GrovePi.I2C.get_last_write(board)
    assert expected_clear_message == GrovePi.I2C.get_last_write(board)
  end

  test "displays text",
  %{board: board} do
    GrovePi.I2C.reset(board)
  end

  defp wait_for_display_initialization do
    Process.sleep(150)
  end
end

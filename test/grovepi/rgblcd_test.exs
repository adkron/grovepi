defmodule GrovePi.RGBLCDTest do
  use ExUnit.Case, async: true

  alias GrovePi.{Board, RGBLCD, I2C}

  @lcd_cmd 0x80
  @lcd_write 0x40

  setup do
    board = Board.i2c_name(Default)
    start_supervised({I2C, ["i2c-1", "address", name: board]})
    %{board: board, config: RGBLCD.get_default_config()}
  end

  test "returns default config" do
    result = RGBLCD.get_default_config()

    assert result ==
      %RGBLCD.Config{
        display_control: 12,
        entry_mode: 6,
        function: 56
      }
  end

  test "autoscroll command", %{board: board, config: config} do
    autoscroll = 0x07

    {:ok, result} = RGBLCD.autoscroll(config)

    assert result.entry_mode == autoscroll
    assert <<@lcd_cmd, autoscroll>> == I2C.get_last_write_data(board)
  end

  test "autoscroll_off command", %{board: board, config: config} do
    autoscroll_off = 0x06

    {:ok, result} = RGBLCD.autoscroll_off(config)

    assert result.entry_mode == autoscroll_off
    assert <<@lcd_cmd, autoscroll_off>> == I2C.get_last_write_data(board)
  end

  test "clear_display command", %{board: board} do
    clear_display = 0x01

    RGBLCD.clear_display()

    assert <<@lcd_cmd, clear_display>> == I2C.get_last_write_data(board)
  end

  test "cursor_blink_off command", %{board: board, config: config} do
    cursor_blink_off = 12

    {:ok, result} = RGBLCD.cursor_blink_off(config)

    assert result.display_control == cursor_blink_off
    assert <<@lcd_cmd, cursor_blink_off>> == I2C.get_last_write_data(board)
  end

  test "cursor_blink_on command", %{board: board, config: config} do
    cursor_blink_on = 13

    {:ok, result} = RGBLCD.cursor_blink_on(config)

    assert result.display_control == cursor_blink_on
    assert <<@lcd_cmd, cursor_blink_on>> == I2C.get_last_write_data(board)
  end

  test "cursor_left command", %{board: board} do
    cursor_left = 20

    :ok = RGBLCD.cursor_left()

    assert <<@lcd_cmd, cursor_left>> == I2C.get_last_write_data(board)
  end

  test "cursor_left command with spaces", %{board: board} do
    cursor_left = 20

    :ok = RGBLCD.cursor_left(3)

    assert I2C.get_all_data(board) ==
      [
        <<@lcd_cmd, cursor_left>>,
        <<@lcd_cmd, cursor_left>>,
        <<@lcd_cmd, cursor_left>>
      ]
  end

  test "cursor_off", %{board: board, config: config} do
    cursor_off = 12

    {:ok, result} = RGBLCD.cursor_off(config)

    assert result.display_control == cursor_off
    assert <<@lcd_cmd, cursor_off>> == I2C.get_last_write_data(board)
  end

  test "cursor_on command", %{board: board, config: config} do
    cursor_on = 14

    {:ok, result} = RGBLCD.cursor_on(config)

    assert result.display_control == cursor_on
    assert <<@lcd_cmd, cursor_on>> == I2C.get_last_write_data(board)
  end

  test "cursor_right command", %{board: board} do
    cursor_right = 16

    :ok = RGBLCD.cursor_right()

    assert <<@lcd_cmd, cursor_right>> == I2C.get_last_write_data(board)
  end

  test "cursor_right command with spaces", %{board: board} do
    cursor_right = 16

    :ok = RGBLCD.cursor_right(3)

    assert I2C.get_all_data(board) ==
      [
        <<@lcd_cmd, cursor_right>>,
        <<@lcd_cmd, cursor_right>>,
        <<@lcd_cmd, cursor_right>>
      ]
  end

  test "display_off command", %{board: board, config: config} do
    display_off = 8

    {:ok, result} = RGBLCD.display_off(config)

    assert result.display_control == display_off
    assert <<@lcd_cmd, display_off>> == I2C.get_last_write_data(board)
  end

  test "display_on command", %{board: board, config: config} do
    display_on = 12

    {:ok, result} = RGBLCD.display_on(config)

    assert result.display_control == display_on
    assert <<@lcd_cmd, display_on>> == I2C.get_last_write_data(board)
  end

  test "home command", %{board: board} do
    home = 0x02

    RGBLCD.home()

    assert <<@lcd_cmd, home>> == I2C.get_last_write_data(board)
  end

  test "initialize command", %{board: board, config: config} do
    lcd_address = 0x3e
    rgb_address = 0x62

    {:ok, result} = RGBLCD.initialize()

    writes = I2C.get_all_writes(board)

    assert config == result
    assert Enum.map(writes, &({&1.address, &1.data})) ==
      [
        {lcd_address, <<@lcd_cmd, 1>>},
        {lcd_address, <<@lcd_cmd, 56>>},
        {lcd_address, <<@lcd_cmd, 12>>},
        {lcd_address, <<@lcd_cmd, 6>>},
        {rgb_address, <<0, 0>>},
        {rgb_address, <<8, 255>>},
        {rgb_address, <<1, 32>>},
        {rgb_address, <<4, 255>>},
        {rgb_address, <<3, 255>>},
        {rgb_address, <<2, 255>>}
      ]
  end

  test "scroll_left command", %{board: board} do
    scroll_left = 28

    :ok = RGBLCD.scroll_left()

    assert <<@lcd_cmd, scroll_left>> == I2C.get_last_write_data(board)
  end

  test "scroll_left command with spaces", %{board: board} do
    scroll_left = 28

    :ok = RGBLCD.scroll_left(3)

    assert I2C.get_all_data(board) ==
      [
        <<@lcd_cmd, scroll_left>>,
        <<@lcd_cmd, scroll_left>>,
        <<@lcd_cmd, scroll_left>>
      ]
  end

  test "scroll_right command", %{board: board} do
    scroll_right = 24

    :ok = RGBLCD.scroll_right()

    assert <<@lcd_cmd, scroll_right>> == I2C.get_last_write_data(board)
  end

  test "scroll_right command with spaces", %{board: board} do
    scroll_right = 24

    :ok = RGBLCD.scroll_right(3)

    assert I2C.get_all_data(board) ==
      [
        <<@lcd_cmd, scroll_right>>,
        <<@lcd_cmd, scroll_right>>,
        <<@lcd_cmd, scroll_right>>
      ]
  end

  test "set_color_white command", %{board: board} do
    reg_red = 4
    reg_green = 3
    reg_blue = 2
    max = 255

    :ok = RGBLCD.set_color_white()

    assert I2C.get_all_data(board) ==
      [
        <<reg_red, max>>,
        <<reg_green, max>>,
        <<reg_blue, max>>
      ]
  end

  test "set_cursor first row", %{board: board} do
    row = 0
    column = 10
    cursor_config = 138

    RGBLCD.set_cursor(row, column)

    assert <<@lcd_cmd, cursor_config>> == I2C.get_last_write_data(board)
  end

  test "set_cursor second row", %{board: board} do
    row = 1
    column = 10
    cursor_config = 202

    RGBLCD.set_cursor(row, column)

    assert <<@lcd_cmd, cursor_config>> == I2C.get_last_write_data(board)
  end

  test "set_cursor second row if over 1", %{board: board} do
    row = 4
    column = 10
    cursor_config = 202

    RGBLCD.set_cursor(row, column)

    assert <<@lcd_cmd, cursor_config>> == I2C.get_last_write_data(board)
  end

  test "set_rgb command", %{board: board} do
    reg_red = 4
    reg_green = 3
    reg_blue = 2
    red = 150
    green = 100
    blue = 50

    :ok = RGBLCD.set_rgb(red, green, blue)

    assert I2C.get_all_data(board) ==
      [
        <<reg_red, red>>,
        <<reg_green, green>>,
        <<reg_blue, blue>>
      ]
  end

  test "set_text command", %{board: board} do
    text = "Hello World"
    clear_display = 0x01

    :ok = RGBLCD.set_text(text)

    assert I2C.get_all_data(board) ==
      [
        <<@lcd_cmd, clear_display>>,
        "@H", "@e", "@l", "@l", "@o", "@ ", "@W", "@o", "@r", "@l", "@d"
      ]
  end

  test "text_left_to_right command", %{board: board, config: config} do
    left_to_right = 6

    {:ok, result} = RGBLCD.text_left_to_right(config)

    assert result.entry_mode == left_to_right
    assert <<@lcd_cmd, left_to_right>> == I2C.get_last_write_data(board)
  end

  test "text_right_to_left command", %{board: board, config: config} do
    right_to_left = 4

    {:ok, result} = RGBLCD.text_right_to_left(config)

    assert result.entry_mode == right_to_left
    assert <<@lcd_cmd, right_to_left>> == I2C.get_last_write_data(board)
  end

  test "write_text command", %{board: board} do
    text = "Hello World"

    :ok = RGBLCD.write_text(text)

    assert I2C.get_all_data(board) ==
      [
        "@H", "@e", "@l", "@l", "@o", "@ ", "@W", "@o", "@r", "@l", "@d"
      ]
  end

  test "send_lcd_cmd command", %{board: board} do
    lcd_address = 0x3e
    cmd = 0x01

    RGBLCD.send_lcd_cmd(cmd)

    write = I2C.get_last_write(board)

    assert lcd_address == write.address
    assert <<@lcd_cmd, cmd>> == write.data
  end

  test "send_lcd_write command", %{board: board} do
    lcd_address = 0x3e
    letter_e = 101

    RGBLCD.send_lcd_write(letter_e)

    write = I2C.get_last_write(board)

    assert lcd_address == write.address
    assert <<@lcd_write, letter_e>> == write.data
  end

  test "send_rgb command", %{board: board} do
    rgb_address = 0x62
    red_reg = 4
    red = 150

    RGBLCD.send_rgb(red_reg, red)

    write = I2C.get_last_write(board)

    assert rgb_address == write.address
    assert <<red_reg, red>> == write.data
  end
end

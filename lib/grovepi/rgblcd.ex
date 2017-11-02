defmodule GrovePi.RGBLCD do
  @moduledoc """
  Conveniences for controlling a RGB LCD Display.  The display should be connected
  to the I2C-1 port.

  Example usage:
  ```
  iex> {:ok, config} = GrovePi.RGBLCD.initialize()
  {:ok, %GrovePi.RGBLCD.Config{display_control: 12, entry_mode: 6, function: 56}}
  iex> {:ok, new_config} = GrovePi.RGBLCD.cursor_on(config)
  {:ok, %GrovePi.RGBLCD.Config{display_control: 14, entry_mode: 6, function: 56}}
  iex> GrovePi.RGBLCD.set_rgb(0, 255, 0)
  :ok
  iex> GrovePi.RGBLCD.set_text("hello world!")
  :ok
  ```
  """

  # References
  # datasheet: https://www.sparkfun.com/datasheets/LCD/HD44780.pdf
  # C++ library: https://github.com/Seeed-Studio/Grove_LCD_RGB_Backlight

  @rgb_address 0x62
  @lcd_address 0x3e

  @reg_red 0x04        # pwm2
  @reg_green 0x03      # pwm1
  @reg_blue 0x02       # pwm0

  @reg_mode1 0x00
  @reg_mode2 0x01
  @reg_output 0x08

  # commands
  @lcd_clear_display 0x01
  @lcd_return_home 0x02
  @lcd_entry_mode 0x04
  @lcd_display_control 0x08
  @lcd_shift 0x10
  @lcd_function 0x20
  # @lcd_set_cg_ram_addr 0x40 ## config unused
  @lcd_set_dd_ram_addr 0x80

  # flags for set entry mode
  @lcd_increment_after_entry 0x02
  # @lcd_decrement_after_entry 0x00 ## config unused
  @lcd_display_shift_on 0x01
  @lcd_display_shift_off 0x00

  # flags for control display
  @lcd_display_on 0x04
  # @lcd_display_off 0x00 ## config unused
  @lcd_cursor_on 0x02
  @lcd_cursor_off 0x00
  @lcd_blink_on 0x01
  @lcd_blink_off 0x00

  # flags for shift cursor or display
  @lcd_move_display 0x08
  @lcd_move_cursor 0x00
  @lcd_move_left 0x04
  @lcd_move_right 0x00

  # flags for set function, must be set during initialization
  @lcd_8_bit_mode 0x10
  # @lcd_4_bit_mode 0x00 ## config unused
  @lcd_2_line 0x08
  # @lcd_1_line 0x00 ## config unused
  # @lcd_5x10_dots 0x04 ## config unused
  @lcd_5x8_dots 0x00

  alias GrovePi.{Board, RGBLCD}
  import Bitwise

  defmodule Config do
    @moduledoc """
    Module with struct to hold GrovePi.RGBLCD configuration
    """
    defstruct entry_mode: :none, display_control: :none, function: :none

    def update_display_control(config, display_control) do
      %{config | display_control: display_control}
    end

    def update_entry_mode(config, entry_mode) do
      %{config | entry_mode: entry_mode}
    end

    def update_function(config, function) do
      %{config | function: function}
    end
  end

  @doc """
  Autoscroll so display moves with cursor
  """
  def autoscroll(%{entry_mode: entry_mode} = config) do
    new_entry_mode =
      entry_mode
      |> set_config(@lcd_entry_mode)
      |> set_config(@lcd_display_shift_on)

    send_lcd_cmd(new_entry_mode)

    {:ok, RGBLCD.Config.update_entry_mode(config, new_entry_mode)}
  end

  @doc """
  Display does not move with cursor
  """
  def autoscroll_off(%{entry_mode: entry_mode} = config) do
    new_entry_mode =
      entry_mode
      |> set_config(@lcd_entry_mode)
      |> set_rev_config(@lcd_display_shift_on)

    send_lcd_cmd(new_entry_mode)

    {:ok, RGBLCD.Config.update_entry_mode(config, new_entry_mode)}
  end

  @doc """
  Clears the LCD Display
  """
  def clear_display() do
    send_lcd_cmd(@lcd_clear_display)
    Process.sleep(50) #cmd takes a long time C++ library slept for 2000
  end

  @doc """
  Turn off blinking the cursor
  """
  def cursor_blink_off(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_rev_config(@lcd_blink_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Turn on blinking the cursor
  """
  def cursor_blink_on(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_config(@lcd_blink_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Moves cursor to the left. Accepts spaces (integer), defaults to 1.
  """
  def cursor_left(spaces \\ 1) do
    for _num <- 1..spaces do
      do_cursor_left()
      Process.sleep(50)
    end
    :ok
  end

  defp do_cursor_left() do
    @lcd_shift
    |> set_config(@lcd_move_cursor)
    |> set_config(@lcd_move_left)
    |> send_lcd_cmd
  end

  @doc """
  Turn off the underline cursor
  """
  def cursor_off(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_rev_config(@lcd_cursor_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Turn on the underline cursor
  """
  def cursor_on(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_config(@lcd_cursor_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Moves cursor to the right. Accepts spaces (integer), defaults to 1.
  """
  def cursor_right(spaces \\ 1) do
    for _num <- 1..spaces do
      do_cursor_right()
      Process.sleep(50)
    end
    :ok
  end

  defp do_cursor_right() do
    @lcd_shift
    |> set_config(@lcd_move_cursor)
    |> set_config(@lcd_move_right)
    |> send_lcd_cmd
  end

  @doc """
  Turns display on quickly
  """
  def display_on(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_config(@lcd_display_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Turns display off quickly
  """
  def display_off(%{display_control: display_control} = config) do
    new_display_control =
      display_control
      |> set_config(@lcd_display_control)
      |> set_rev_config(@lcd_display_on)

    send_lcd_cmd(new_display_control)

    {:ok, RGBLCD.Config.update_display_control(config, new_display_control)}
  end

  @doc """
  Returns a GrovePi.RGBLCD.Config struct with default configuration.
  - 2 Line
  - 8 bit mode
  - 5x8 dots
  - display on
  - cursor off
  - blink off
  - increment after entry (right to left)
  - display shift (autoscroll) off
  """
  def get_default_config() do
    function_config =
      @lcd_function
      |> set_config(@lcd_2_line)
      |> set_config(@lcd_8_bit_mode)
      |> set_config(@lcd_5x8_dots)

    display_control_config =
      @lcd_display_control
      |> set_config(@lcd_display_on)
      |> set_config(@lcd_cursor_off)
      |> set_config(@lcd_blink_off)

    entry_mode_config =
      @lcd_entry_mode
      |> set_config(@lcd_increment_after_entry)
      |> set_config(@lcd_display_shift_off)

    %RGBLCD.Config{}
    |> RGBLCD.Config.update_function(function_config)
    |> RGBLCD.Config.update_display_control(display_control_config)
    |> RGBLCD.Config.update_entry_mode(entry_mode_config)
  end

  @doc """
  Sets cursor position to zero
  """
  def home() do
    send_lcd_cmd(@lcd_return_home)
    Process.sleep(50) #cmd takes a long time C++ library slept for 2000
  end

  @doc """
  Initializes the LCD Display.  Returns tuple with :ok, and
  %GrovePi.RGBLCD.Config{} with initial configuration.
  """
  def initialize() do
    clear_display()

    config = get_default_config()

    send_lcd_cmd(config.function)
    send_lcd_cmd(config.display_control)
    send_lcd_cmd(config.entry_mode)

    #backlit init
    send_rgb(@reg_mode1, 0)

    # set LEDs controllable by both PWM and GRPPWM registers
    send_rgb(@reg_output, 0xff)

    # set reg_mode2 values
    # 0010 0000 -> 0x20 (DMBLNK to 1, ie blinky mode)
    send_rgb(@reg_mode2, 0x20)

    set_color_white()

    {:ok, config}
  end

  @doc """
  Scroll display left. Accepts spaces (integer) as an argument, defaults to 1.
  """
  def scroll_left(spaces \\ 1) do
    for _num <- 1..spaces do
      do_scroll_left()
      Process.sleep(50)
    end
    :ok
  end

  defp do_scroll_left() do
    @lcd_shift
    |> set_config(@lcd_move_display)
    |> set_config(@lcd_move_left)
    |> send_lcd_cmd
  end

  @doc """
  Scroll display right. Accepts spaces (integer) as an argument, defaults to 1.
  """
  def scroll_right(spaces \\ 1) do
    for _num <- 1..spaces do
      do_scroll_right()
      Process.sleep(50)
    end
    :ok
  end

  defp do_scroll_right() do
    @lcd_shift
    |> set_config(@lcd_move_display)
    |> set_config(@lcd_move_right)
    |> send_lcd_cmd
  end

  @doc """
  Sets display to white (255 for Red, Green, and Blue)
  """
  def set_color_white() do
    set_rgb(255, 255, 255)
  end

  @doc """
  Sets cursor given row and value. Home position is (0, 0).
  """
  def set_cursor(0, col) do
    @lcd_set_dd_ram_addr
    |> set_config(col)
    |> send_lcd_cmd
  end

  def set_cursor(_row, col) do
    row2 = 0x40

    @lcd_set_dd_ram_addr
    |> set_config(col)
    |> set_config(row2)
    |> send_lcd_cmd
  end

  @doc """
  Sets the red, green, and blue values for a RGB LCD Display. Accepts an integer
  from 0 - 255 for each color.
  """
  def set_rgb(red, green, blue) do
    send_rgb(@reg_red, red)
    send_rgb(@reg_green, green)
    send_rgb(@reg_blue, blue)
  end

  @doc """
  Updates the text on a RGB LCD Display. Deletes existing text.
  """
  def set_text(text) do
    clear_display()
    send_chars(text)
  end

  @doc """
  Set text flow from left to right
  """
  def text_left_to_right(%{entry_mode: entry_mode} = config) do
    new_entry_mode =
      entry_mode
      |> set_config(@lcd_entry_mode)
      |> set_config(@lcd_increment_after_entry)

    send_lcd_cmd(new_entry_mode)

    {:ok, RGBLCD.Config.update_entry_mode(config, new_entry_mode)}
  end

  @doc """
  Set text flow from right to left
  """
  def text_right_to_left(%{entry_mode: entry_mode} = config) do
    new_entry_mode =
      entry_mode
      |> set_config(@lcd_entry_mode)
      |> set_rev_config(@lcd_increment_after_entry)

    send_lcd_cmd(new_entry_mode)

    {:ok, RGBLCD.Config.update_entry_mode(config, new_entry_mode)}
  end

  @doc """
  Write text at cursor.  Does not delete existing text.
  """
  def write_text(text) do
    send_chars(text)
  end

  defp send_chars(<<>>), do: :ok
  defp send_chars(<<?\n, rest::binary>>) do
    set_cursor(1, 0)
    send_chars(rest)
  end
  defp send_chars(<<text, rest::binary>>) do
    send_lcd_write(text)
    send_chars(rest)
  end

  @doc false
  def send_lcd_cmd(cmd) do
    Board.i2c_write_device(@lcd_address, <<0x80, cmd>>)
  end

  @doc false
  def send_lcd_write(text) do
    Board.i2c_write_device(@lcd_address, <<0x40, text>>)
  end

  @doc false
  def send_rgb(address, value) do
    Board.i2c_write_device(@rgb_address, <<address, value>>)
  end

  defp set_config(config, addl_config) do
    config ||| addl_config
  end

  defp set_rev_config(config, addl_config) do
    config &&& ~~~addl_config
  end
end

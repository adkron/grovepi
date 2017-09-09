defmodule DemoRGBLCD do
  @moduledoc """
  Sample functions to demonstrate and test GrovePi.RGBLCD module
  """

  # References
  # C++ library: https://github.com/Seeed-Studio/Grove_LCD_RGB_Backlight

  alias GrovePi.RGBLCD

  @doc """
  Shows autoscroll function
  """
  def autoscroll() do
    {:ok, config} = RGBLCD.start()
    print_autoscroll(config)
  end

  defp print_autoscroll(config) do
    RGBLCD.set_cursor(0, 0)
    IO.inspect(config)
    print_nums()

    RGBLCD.set_cursor(1, 16)
    {:ok, new_config} = RGBLCD.autoscroll(config)
    IO.inspect(new_config)
    print_nums()

    RGBLCD.scroll_left(10)
    RGBLCD.clear_display()

    {:ok, new_config} = RGBLCD.autoscroll_off(new_config)
    print_autoscroll(new_config)
  end

  @doc """
  Toggles cursor blinking on and off every 3000ms
  """
  def blink() do
    {:ok, config} = RGBLCD.start
    RGBLCD.set_text("hello world!")
    toggle_blink(config)
  end

  defp toggle_blink(config) do
    {:ok, new_config} = RGBLCD.cursor_blink_on(config)
    Process.sleep(3000)
    {:ok, new_config} = RGBLCD.cursor_blink_off(new_config)
    Process.sleep(3000)
    toggle_blink(new_config)
  end

  @doc """
  Toggles the cursor on and off every 1500ms
  """
  def cursor() do
    {:ok, config} = RGBLCD.start
    RGBLCD.set_text("hello world!")
    toggle_cursor(config)
  end

  defp toggle_cursor(config) do
    {:ok, new_config} = RGBLCD.cursor_on(config)
    Process.sleep(1500)
    {:ok, new_config} = RGBLCD.cursor_off(new_config)
    Process.sleep(1500)
    toggle_cursor(new_config)
  end

  @doc """
  Demonstrates setting the RGB color
  """
  def colors() do
    {:ok, _config} = RGBLCD.start()
    toggle_colors()
  end

  defp toggle_colors() do
    RGBLCD.set_rgb(255, 0, 0)
    Process.sleep(1500)
    RGBLCD.set_rgb(0, 255, 0)
    Process.sleep(1500)
    RGBLCD.set_rgb(0, 0, 255)
    Process.sleep(1500)
    RGBLCD.set_rgb(:rand.uniform(255), :rand.uniform(255), :rand.uniform(255))
    Process.sleep(1500)
    toggle_colors()
  end

  @doc """
  Toggles the display on and off every 1500ms
  """
  def display() do
    {:ok, config} = RGBLCD.start
    RGBLCD.set_text("hello world!")
    toggle_display(config)
  end

  defp toggle_display(config) do
    {:ok, new_config} = RGBLCD.display_on(config)
    Process.sleep(1500)
    {:ok, new_config} = RGBLCD.display_off(new_config)
    Process.sleep(1500)
    toggle_display(new_config)
  end

  @doc """
  Prints 0 to 9 with 500ms delay between numbers
  """
  def print_nums do
    for num <- 0..9 do
      num
      |> Integer.to_string
      |> RGBLCD.write_text

      IO.puts(num)

      Process.sleep(500)
    end
  end

  @doc """
  Demonstrates text direction both ways
  """
  def text_direction() do
    {:ok, config} = RGBLCD.start()
    do_text_direction(config)
  end

  defp do_text_direction(config) do
    IO.inspect(config)
    print_nums()
    {:ok, new_config} = RGBLCD.text_right_to_left(config)
    IO.inspect(new_config)
    print_nums()
    {:ok, new_config} = RGBLCD.text_left_to_right(new_config)
    do_text_direction(new_config)
  end

  @doc """
  Demonstrates moving the cursor to the second line
  """
  def set_cursor() do
    {:ok, config} = RGBLCD.start()
    {:ok, _new_config} = RGBLCD.cursor_on(config)
    do_set_cursor()
  end

  defp do_set_cursor() do
    RGBLCD.set_cursor(0, 5)
    Process.sleep(1000)
    print_nums()
    RGBLCD.set_cursor(1, 3)
    Process.sleep(1000)
    print_nums()
    RGBLCD.clear_display()
    do_set_cursor()
  end
end

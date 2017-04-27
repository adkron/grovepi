defmodule GrovePi.Digital do
  alias GrovePi.Board

  @moduledoc """
  Write to and read digital I/O on the GrovePi.

  Example usage:
  ```
  iex> pin = 3

  iex> GrovePi.Digital.set_pinmode(pin, :input)
  :ok
  iex> GrovePi.Digital.write(pin, 1)
  :ok
  iex> GrovePi.Digital.write(pin, 0)
  :ok
  iex> GrovePi.Digital.set_pinmode(pin, :output)
  :ok
  iex> GrovePi.Digital.read(pin, 0)
  1
  ```

  """

  def set_pin_mode(prefix, pin, pin_mode) do
    Board.send_request(prefix, <<5, pin, mode(pin_mode), 0>>)
  end

  def set_pin_mode(pin, pin_mode) do
    set_pin_mode(Default, pin, pin_mode)
  end

  def read(prefix, pin) do
    :ok = Board.send_request(prefix, <<1, pin, 0, 0>>)
    <<value>> = Board.get_response(prefix, 1)
    value
  end

  def read(pin) do
    read(Default, pin)
  end

  def write(prefix, pin, value) when value == 0 or value == 1 do
    Board.send_request(prefix, <<2, pin, value, 0>>)
  end

  def write(pin, value) do
    write(Default, pin, value)
  end

  defp mode(:input), do: 0
  defp mode(:output), do: 1
end

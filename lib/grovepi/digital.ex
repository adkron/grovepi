defmodule GrovePi.Digital do
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

  @board GrovePi.Board

  def set_pin_mode(pin, pin_mode) do
    GrovePi.Board.send_request(<<5, pin, mode(pin_mode), 0>>)
  end

  def read(board, pin) do
    :ok = GrovePi.Board.send_request(board, <<1, pin, 0, 0>>)
    <<value>> = GrovePi.Board.get_response(board, 1)
    value
  end

  def read(pin) do
    read(@board, pin)
  end

  def write(pin, value) when value == 0 or value == 1 do
    GrovePi.Board.send_request(<<2, pin, value, 0>>)
  end

  defp mode(:input), do: 0
  defp mode(:output), do: 1
end

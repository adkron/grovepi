defmodule GrovePi.Digital do
  alias GrovePi.Board

  @moduledoc """
  Write to and read digital I/O on the GrovePi. This module provides a low
  level API to digital sensors.

  Example usage:
  ```
  iex> pin = 3

  iex> GrovePi.Digital.set_pin_mode(pin, :input)
  :ok
  iex> GrovePi.Digital.write(pin, 1)
  :ok
  iex> GrovePi.Digital.write(pin, 0)
  :ok
  iex> GrovePi.Digital.set_pin_mode(pin, :output)
  :ok
  iex> GrovePi.Digital.read(pin, 0)
  1
  ```
  """

  @type pin_mode :: :input | :output
  @type level :: 0 | 1

  @spec set_pin_mode(atom, GrovePi.pin, pin_mode) :: :ok | {:error, term}
  def set_pin_mode(prefix, pin, pin_mode) do
    Board.send_request(prefix, <<5, pin, mode(pin_mode), 0>>)
  end

  @doc """
  Configure a digital I/O pin to be an `:input` or an `:output`.
  """
  @spec set_pin_mode(GrovePi.pin, pin_mode) :: :ok | {:error, term}
  def set_pin_mode(pin, pin_mode) do
    set_pin_mode(Default, pin, pin_mode)
  end

  @spec read(atom, GrovePi.pin) :: level | {:error, term}
  def read(prefix, pin) do
    with :ok <- Board.send_request(prefix, <<1, pin, 0, 0>>),
         <<value>> = Board.get_response(prefix, 1),
      do: value
  end

  @doc """
  Read the value on a digital I/O pin. Before this is called, the pin must be
  configured as an `:input` with `set_pin_mode/2` or `set_pin_mode/3`.
  """
  @spec read(GrovePi.pin) :: level | {:error, term}
  def read(pin) do
    read(Default, pin)
  end

  @spec write(atom, GrovePi.pin, level) :: :ok | {:error, term}
  def write(prefix, pin, value) when value == 0 or value == 1 do
    Board.send_request(prefix, <<2, pin, value, 0>>)
  end

  @doc """
  Write a value on a digital I/O pin. Before this is called, the pin must be
  configured as an `:output` with `set_pin_mode/2` or `set_pin_mode/3`. Valid
  values are `0` (low) and `1` (high).
  """
  @spec write(GrovePi.pin, level) :: :ok | {:error, term}
  def write(pin, value) do
    write(Default, pin, value)
  end

  defp mode(:input), do: 0
  defp mode(:output), do: 1
end

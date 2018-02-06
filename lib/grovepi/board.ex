defmodule GrovePi.Board.Behaviour do
  @type device ::
  %{
    :address => GrovePi.I2C.address,
    optional(any) => any,
  } |
  %{
    :pin => GrovePi.pin,
    optional(any) => any,
  }

  @type bytes_count :: integer

  @callback read(device, bytes_count) :: binary
end
defmodule GrovePi.Board do
  @moduledoc """
  Low-level interface for sending raw requests and receiving responses from a
  GrovePi hat. Create one of these first and then use one of the other GrovePi
  modules for interacting with a connected sensor, light, or actuator.

  To check that your GrovePi hardware is working, try this:

  ```elixir
  iex> GrovePi.Board.firmware_version()
  "1.2.2"
  ```

  """

  @behaviour GrovePi.Board.Behaviour

  use GrovePi.I2C
  @i2c_retry_count 2

  @doc """
  """
  @spec start_link(byte, atom) :: {:ok, pid} | {:error, any}
  def start_link(address, prefix, opts \\ []) when is_integer(address) do
    opts = Keyword.put_new(opts, :name, i2c_name(prefix))
    @i2c.start_link("i2c-1", address, opts)
  end

  def i2c_name(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end

  @doc """
  Get the version of firmware running on the GrovePi's microcontroller.
  """
  @spec firmware_version(atom) :: binary | {:error, term}
  def firmware_version(prefix \\ Default) do
    with :ok <- send_request(prefix, <<8, 0, 0, 0>>),
         <<_, major, minor, patch>> <- get_response(prefix, 4),
         do: "#{major}.#{minor}.#{patch}"
  end

  @doc """
  Send a request to the GrovePi. This is not normally called directly
  except when interacting with an unsupported sensor.
  """
  @spec send_request(GenServer.server, binary) :: :ok | {:error, term}
  def send_request(prefix, message) when byte_size(message) == 4 do
    send_request_with_retry(i2c_name(prefix), message, @i2c_retry_count)
  end

  def send_request(message) do
    send_request(Default, message)
  end

  @doc """
  Get a response to a previously send request to the GrovePi. This is
  not normally called directly.
  """
  @spec get_response(atom, integer) :: binary | {:error, term}
  def get_response(prefix, len) do
    get_response_with_retry(i2c_name(prefix), len, @i2c_retry_count)
  end

  @spec get_response(integer) :: binary | {:error, term}
  def get_response(len) do
    get_response(Default, len)
  end

  @doc """
  Read the number of bytes from the given address
  """
  def read(%{address: address}, bytes_count) do
    @i2c.read_device(i2c_name(Default), address, bytes_count)
  end

  @doc """
  Write directly to a device on the I2C bus. This is used for sensors
  that are not controlled by the GrovePi's microcontroller.
  """
  def i2c_write_device(address, buffer) do
    @i2c.write_device(i2c_name(Default), address, buffer)
  end

  # The GrovePi has intermittent I2C communication failures. These
  # are usually harmless, so automatically retry.
  defp send_request_with_retry(_board, _message, 0), do: {:error, :too_many_retries}
  defp send_request_with_retry(board, message, retries_left) do
    case @i2c.write(board, message) do
      {:error, _} -> send_request_with_retry(board, message, retries_left - 1)
      response -> response
    end
  end

  defp get_response_with_retry(_board, _len, 0), do: {:error, :too_many_retries}
  defp get_response_with_retry(board, len, retries_left) do
    case @i2c.read(board, len) do
      {:error, _} -> get_response_with_retry(board, len, retries_left - 1)
      response -> response
    end
  end
end

defmodule GrovePi.Board do
  @moduledoc """
  Low-level interface for sending raw requests and receiving responses from a
  GrovePi hat. Create one of these first and then use one of the other GrovePi
  modules for interacting with a connected sensor, light, or actuator.

  To check that your GrovePi hardware is working, try this:

  ```
  iex> GrovePi.Board.firmware_version()
  "1.2.2"
  ```

  """

  use GrovePi.I2C

  @doc """
  """
  @spec start_link(byte) :: {:ok, pid} | {:error, any}
  def start_link(address, opts \\ []) when is_integer(address) do
    opts = Keyword.put(opts, :name, __MODULE__)
    @i2c.start_link("i2c-1", address, opts)
  end


  @doc """
  Get the version of firmware running on the GrovePi's microcontroller.
  """
  @spec firmware_version() :: binary | {:error, term}
  def firmware_version() do
    with :ok <- send_request(<<8, 0, 0, 0>>),
         <<_, major, minor, patch>> <- get_response(4),
         do: "#{major}.#{minor}.#{patch}"
  end

  @doc """
  Send a request to the GrovePi. This is not normally called directly
  except when interacting with an unsupported sensor.
  """
  @spec send_request(binary) :: :ok
  def send_request(message) when byte_size(message) == 4 do
    @i2c.write(__MODULE__, message)
  end

  @doc """
  Get a response to a previously send request to the GrovePi. This is
  not normally called directly.
  """
  def get_response(len) do
    @i2c.read(__MODULE__, len)
  end

  def i2c_write_device(address, buffer) do
    @i2c.write_device(__MODULE__, address, buffer)
  end
end

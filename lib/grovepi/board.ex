defmodule GrovePi.Board do
  @moduledoc """
  Low-level interface for sending raw requests and receiving responses from a
  GrovePi hat. Automatically started with GrovePi, allows you to use one of the other GrovePi
  modules for interacting with a connected sensor, light, or actuator.

  To check that your GrovePi hardware is working, try this:

  ```elixir
  iex> GrovePi.Board.firmware_version()
  "1.2.2"
  ```

  """

  use GenServer
  @i2c Application.get_env(:grovepi, :i2c, Circuits.I2C)
  @i2c_retry_count 2

  defstruct address: nil, i2c_bus: nil

  ## Client API

  @spec start_link(byte, atom) :: {:ok, pid} | {:error, any}
  def start_link(address, prefix, opts \\ []) when is_integer(address) do
    opts = Keyword.put_new(opts, :name, i2c_name(prefix))
    state = %__MODULE__{address: address}
    GenServer.start_link(__MODULE__, state, opts)
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
  @spec send_request(GenServer.server(), binary) :: :ok | {:error, term}
  def send_request(prefix, message) when byte_size(message) == 4 do
    GenServer.call(i2c_name(prefix), {:write, message})
  end

  def send_request(message) do
    send_request(Default, message)
  end

  @doc """
  Get a response to a previously send request to the GrovePi. This is
  not normally called directly.
  """
  @spec get_response(atom, integer) :: binary | {:error, term}
  def get_response(prefix, bytes_to_read) do
    GenServer.call(i2c_name(prefix), {:read, bytes_to_read})
  end

  @spec get_response(integer) :: binary | {:error, term}
  def get_response(bytes_to_read) do
    get_response(Default, bytes_to_read)
  end

  @doc """
  Write directly to a device on the I2C bus. This is used for sensors
  that are not controlled by the GrovePi's microcontroller.
  """
  def i2c_write_device(address, message) do
    GenServer.call(i2c_name(Default), {:write_device, address, message})
  end

  #### test helper functions

  def add_responses(board, messages) do
    GenServer.call(board, {:add_responses, messages})
  end

  def add_response(board, message) do
    add_responses(board, [message])
  end

  def get_last_write(board) do
    GenServer.call(board, {:get_last_write})
  end

  def get_last_write_data(board) do
    GenServer.call(board, {:get_last_write_data})
  end

  def get_all_writes(board) do
    GenServer.call(board, {:get_all_writes})
  end

  def get_all_data(board) do
    GenServer.call(board, {:get_all_data})
  end

  def reset(board) do
    GenServer.call(board, :reset)
  end

  ## Server Callbacks

  @impl true
  def init(state) do
    {:ok, state, {:continue, :open_i2c}}
  end

  @impl true
  def handle_continue(:open_i2c, state) do
    {:ok, ref} = @i2c.open("i2c-1")
    {:noreply, %{state | i2c_bus: ref}}
  end

  @impl true
  def handle_call({:write, message}, _from, state) do
    reply = @i2c.write(state.i2c_bus, state.address, message, retries: @i2c_retry_count)
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:write_device, address, message}, _from, state) do
    reply = @i2c.write(state.i2c_bus, address, message, retries: @i2c_retry_count)
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:read, bytes_to_read}, _from, state) do
    reply =
      case(@i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: @i2c_retry_count)) do
        {:ok, response} -> response
        {:error, error} -> {:error, error}
      end

    {:reply, reply, state}
  end

  ### test helper callbacks

  def handle_call({:get_last_write}, _from, state) do
    {:reply, @i2c.get_last_write(state.i2c_bus), state}
  end

  def handle_call({:get_last_write_data}, _from, state) do
    {:reply, @i2c.get_last_write_data(state.i2c_bus), state}
  end

  def handle_call({:get_all_writes}, _from, state) do
    {:reply, @i2c.get_all_writes(state.i2c_bus), state}
  end

  def handle_call({:get_all_data}, _from, state) do
    {:reply, @i2c.get_all_data(state.i2c_bus), state}
  end

  def handle_call({:add_responses, responses}, _from, state) do
    {:reply, @i2c.add_responses(state.i2c_bus, responses), state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, @i2c.reset(state.i2c_bus), state}
  end
end

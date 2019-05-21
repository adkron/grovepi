defmodule GrovePi.I2C do
  @moduledoc false

  use GenServer

  alias GrovePi.I2C.{State, Write}

  @type i2c_address :: 0..127

  def init(args) do
    {:ok, args}
  end

  @spec open(binary) :: {:ok, pid}
  def open(_bus_name) do
    GenServer.start_link(__MODULE__, %State{}, [])
  end

  def add_responses(pid, messages) do
    GenServer.call(pid, {:add_responses, messages})
  end

  def add_response(pid, message) do
    GenServer.call(pid, {:add_responses, [message]})
  end

  def get_last_write(pid) do
    GenServer.call(pid, {:get_last_write})
  end

  def get_last_write_data(pid) do
    GenServer.call(pid, {:get_last_write_data})
  end

  def get_all_writes(pid) do
    GenServer.call(pid, {:get_all_writes})
  end

  def get_all_data(pid) do
    GenServer.call(pid, {:get_all_data})
  end

  @spec write(pid, i2c_address, binary, list) :: :ok
  def write(pid, address, message, _opts) do
    GenServer.call(pid, {:write, address, message})
  end

  def read(pid, _address, len, _opts) do
    GenServer.call(pid, {:read, len})
  end

  def reset(pid) do
    GenServer.call(pid, :reset)
  end

  def handle_call({:write, address, message}, _from, state) do
    {:reply, :ok, State.add_input(state, %Write{address: address, data: message})}
  end

  def handle_call({:get_last_write}, _from, state) do
    {write, new_state} = State.pop_last_write(state)
    {:reply, write, new_state}
  end

  def handle_call({:get_last_write_data}, _from, state) do
    {data, new_state} = State.pop_last_write_data(state)
    {:reply, data, new_state}
  end

  def handle_call({:get_all_writes}, _from, state) do
    {writes, new_state} = State.pop_all_writes(state)
    {:reply, writes, new_state}
  end

  def handle_call({:get_all_data}, _from, state) do
    {data, new_state} = State.pop_all_data(state)
    {:reply, data, new_state}
  end

  def handle_call({:read, _len}, _from, state) do
    {message, new_state} = State.pop_last_response(state)
    {:reply, {:ok, message}, new_state}
  end

  def handle_call({:add_responses, responses}, _from, state) do
    {:reply, :ok, State.add_responses(state, responses)}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %State{}}
  end
end

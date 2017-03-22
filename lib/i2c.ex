defmodule GrovePi.I2C do
  use GenServer

  @type i2c_address :: 0..127
  @low 0
  @high 1

  defmodule State do
    defstruct level: @low, current_pin: nil
  end

  @spec start_link(binary, i2c_address, [term]) :: {:ok, pid}
  def start_link(_devname, _address, opts \\ []) do
    GenServer.start_link(__MODULE__, %State{})
  end

  def set_level(pid, level) do
    GenServer.call(pid, {:set_level, level})
  end

  @spec write(pid, binary) :: :ok
  def write(pid, <<1, pin, 0, 0>>) do
    GenServer.call(pid, {:write, pin})
  end

  def read(pid, 1) do
    GenServer.call(pid, {:read, 1})
  end

  def handle_call({:write, pin}, _from, state) do
    {:reply, :ok, %{state | current_pin: pin}}
  end

  def handle_call({:read,  1}, _from, state) do
    {:reply, state.level, %{state | current_pin: nil}}
  end

  def handle_call({:set_level, level}, _from, state) do
    {:reply, :ok, %{state | level: level}}
  end
end

defmodule GrovePi.I2C do
  use GenServer

  @type i2c_address :: 0..127

  defmodule State do
    defstruct output_messages: [], input_messages: []
  end

  @spec start_link(binary, i2c_address, [term]) :: {:ok, pid}
  def start_link(_devname, _address, _opts \\ []) do
    GenServer.start_link(__MODULE__, %State{})
  end

  def add_responses(pid, messages) do
    GenServer.call(pid, {:add_responses, messages})
  end

  def add_response(pid, message) do
    GenServer.call(pid, {:add_responses, [message]})
  end

  @spec write(pid, binary) :: :ok
  def write(pid, <<1, _pin, 0, 0>> = message) do
    GenServer.call(pid, {:write, message})
  end

  def read(pid, len) do
    GenServer.call(pid, {:read, len})
  end

  def handle_call({:write, message}, _from, state) do
    {:reply, :ok, %{state | input_messages: [message, state.input_messages]}}
  end

  def handle_call({:read,  _len}, _from, %State{output_messages: []} = state) do
    {:reply, <<0>>, state}
  end

  def handle_call({:read,  _len}, _from, %State{output_messages: output_messages} = state) do
    [message | rest_output_messages] = output_messages
    {:reply, message, %{state | output_messages: rest_output_messages}}
  end

  def handle_call({:add_responses, messages}, _from, state) do
    {:reply, :ok, %{state | output_messages: state.output_messages ++ messages}}
  end

  def write_device(_,_,_), do: :ok
end

defmodule GrovePi.I2C do
  use GenServer

  defmacro __using__(_) do
    quote do
      @i2c Application.get_env(:grovepi, :i2c, ElixirALE.I2C)
    end
  end

  @type i2c_address :: 0..127

  defmodule State do
    @moduledoc false
    defstruct output_messages: [], input_messages: []

    def add_input(%State{} = state, message) do
      %{state |
        input_messages: [add_time_to_messages(message) | state.input_messages]
      }
    end

    def add_responses(%State{} = state, responses) do
      %{state | output_messages: state.output_messages ++ responses}
    end

    def pop_last_write(%State{} = state) do
      {message_pack, rest} = pop_or_error(state.input_messages)
      new_state = %{state | input_messages: rest}
      {message_pack, new_state}
    end

    def pop_last_response(%State{output_messages: []} = state) do
      {<<0>>, state}
    end

    def pop_last_response(%State{output_messages: output_messages} = state) do
      [message | rest_output_messages] = output_messages
      {message, %{state | output_messages: rest_output_messages}}
    end

    defp pop_or_error([]), do: {{:error, :no_more_messages}, []}
    defp pop_or_error([head | tail]), do: {head, tail}

    defp add_time_to_messages(message) do
      {System.monotonic_time(:millisecond), message}
    end
  end

  @spec start_link(binary, i2c_address, [term]) :: {:ok, pid}
  def start_link(_devname, _address, opts \\ []) do
    GenServer.start_link(__MODULE__, %State{}, opts)
  end

  def add_responses(pid, messages) do
    GenServer.call(pid, {:add_responses, messages})
  end

  def add_response(pid, message) do
    GenServer.call(pid, {:add_responses, [message]})
  end

  def get_last_write(pid, opts \\ []) do
    GenServer.call(pid, {:get_last_write, opts})
  end

  @spec write(pid, binary) :: :ok
  def write(pid, message) do
    GenServer.call(pid, {:write, message})
  end

  def read(pid, len) do
    GenServer.call(pid, {:read, len})
  end

  def reset(pid) do
    GenServer.call(pid, :reset)
  end

  def write_device(_,_,_), do: :ok

  def handle_call({:write, message}, _from, state) do
    {:reply, :ok, State.add_input(state, message)}
  end

  def handle_call({:get_last_write, [include_time: true]}, _from, state) do
    {message_pack, new_state} = State.pop_last_write(state)
    {:reply, message_pack, new_state}
  end

  def handle_call({:get_last_write, []}, _from, state) do
    {{_, message}, new_state} = State.pop_last_write(state)
    {:reply, message, new_state}
  end

  def handle_call({:read,  _len}, _from, state) do
    {message, new_state} = State.pop_last_response(state)
    {:reply, message, new_state}
  end

  def handle_call({:add_responses, responses}, _from, state) do
    {:reply, :ok, State.add_responses(state, responses)}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %State{}}
  end
end

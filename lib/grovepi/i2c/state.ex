defmodule GrovePi.I2C.State do
  alias __MODULE__
  @enforce_keys :address
  defstruct responses: [], writes: [], address: nil
  @moduledoc false

  def add_input(%State{} = state, {address, message}) do
    %{state |
      writes: [add_time_to_messages(address, message) | state.writes]
    }
  end

  def add_input(%State{address: address} = state, message) do
    add_input(state, {address, message})
  end

  def add_responses(%State{} = state, responses) do
    %{state | responses: state.responses ++ responses}
  end

  def pop_last_write(%State{} = state) do
    {message_pack, rest} = pop_or_error(state.writes)
    new_state = %{state | writes: rest}
    {message_pack, new_state}
  end

  def pop_last_response(%State{responses: []} = state) do
    {<<0>>, state}
  end

  def pop_last_response(%State{responses: responses} = state) do
    [message | rest_responses] = responses
    {message, %{state | responses: rest_responses}}
  end

  defp pop_or_error([]), do: {{:error, :no_address, :no_more_messages}, []}
  defp pop_or_error([head | tail]), do: {head, tail}

  defp add_time_to_messages(address, message) do
    {System.monotonic_time(:millisecond), address, message}
  end
end

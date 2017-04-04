defmodule GrovePi.I2C.State do
  alias __MODULE__
  defstruct responses: [], writes: []
  @moduledoc false

  def add_input(%State{} = state, message) do
    %{state |
      writes: [add_time_to_messages(message) | state.writes]
    }
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

  defp pop_or_error([]), do: {{:error, :no_more_messages}, []}
  defp pop_or_error([head | tail]), do: {head, tail}

  defp add_time_to_messages(message) do
    {System.monotonic_time(:millisecond), message}
  end
end

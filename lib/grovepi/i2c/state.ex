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

  def pop_all_writes(%State{writes: []} = state) do
    {:no_messages, state}
  end

  def pop_all_writes(%State{} = state) do
    {messages, new_state} = get_all_messages(state)
    ordered_messages = Enum.reverse(messages)
    {ordered_messages, new_state}
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

  def remove_time_from_message_packs(message_packs) do
    Enum.map(message_packs, &remove_time_from_message/1)
  end

  defp get_all_messages(state) do
    Map.get_and_update(state, :writes, fn messages ->
      {messages, []}
    end)
  end

  defp pop_or_error([]), do: {{:error, :no_more_messages}, []}
  defp pop_or_error([head | tail]), do: {head, tail}

  defp add_time_to_messages(message) do
    {System.monotonic_time(:millisecond), message}
  end

  defp remove_time_from_message({_time, message}) do
    message
  end
end

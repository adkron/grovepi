defmodule GrovePi.I2C.State do
  @moduledoc false

  alias __MODULE__

  defstruct responses: [], writes: []

  def add_input(%State{} = state, write) do
    %{state | writes: [add_time_to_write(write) | state.writes]}
  end

  def add_responses(%State{} = state, responses) do
    %{state | responses: state.responses ++ responses}
  end

  def pop_all_writes(%State{writes: []} = state) do
    {{:error, :no_more_messages}, state}
  end

  def pop_all_writes(%State{} = state) do
    Map.get_and_update(state, :writes, &rev_and_update_writes(&1))
  end

  def pop_all_data(%State{writes: []} = state) do
    {{:error, :no_more_messages}, state}
  end

  def pop_all_data(%State{} = state) do
    {writes, new_state} = pop_all_writes(state)
    data = get_all_data(writes)
    {data, new_state}
  end

  def pop_last_write(%State{} = state) do
    {write, rest} = pop_or_error(state.writes)
    new_state = %{state | writes: rest}
    {write, new_state}
  end

  def pop_last_write_data(%State{} = state) do
    {write, new_state} = pop_last_write(state)
    data = get_data(write)
    {data, new_state}
  end

  def pop_last_response(%State{responses: []} = state) do
    {{:error, :no_more_messages}, state}
  end

  def pop_last_response(%State{responses: responses} = state) do
    [message | rest_responses] = responses
    {message, %{state | responses: rest_responses}}
  end

  defp rev_and_update_writes(messages) do
    ordered_messages = Enum.reverse(messages)
    {ordered_messages, []}
  end

  defp pop_or_error([]), do: {{:error, :no_more_messages}, []}
  defp pop_or_error([head | tail]), do: {head, tail}

  defp add_time_to_write(write) do
    %{write | time: System.monotonic_time(:millisecond)}
  end

  defp get_all_data(writes) do
    Enum.map(writes, & &1.data)
  end

  defp get_data({:error, error}), do: {:error, error}
  defp get_data(%{data: data}), do: data
end

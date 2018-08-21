defmodule GrovePi.IRReflective.DefaultTrigger do
  @behaviour GrovePi.Trigger

  @moduledoc """
  This is the default triggering mechanism for IRReflective events. Events
  are either `close` or `far` and include the trigger state.
  The trigger state for the default trigger is a struct containing
  a `value` property.

  ## Examples
      iex> GrovePi.IRReflective.DefaultTrigger.init([])
      {:ok, %GrovePi.IRReflective.DefaultTrigger.State{value: 0}}

      iex> GrovePi.IRReflective.DefaultTrigger.update(0, %{value: 0})
      {:ok, %{value: 0}}

      iex> GrovePi.IRReflective.DefaultTrigger.update(1, %{value: 1})
      {:ok, %{value: 1}}

      iex> GrovePi.IRReflective.DefaultTrigger.update(0, %{value: 1})
      {:released, %{value: 0}}

      iex> GrovePi.IRReflective.DefaultTrigger.update(1, %{value: 0})
      {:pressed, %{value: 1}}
  """

  defmodule State do
    @moduledoc false
    defstruct value: 1
  end

  def init(_) do
    {:ok, %State{}}
  end

  def update(value, %{value: value} = state), do: {:ok, state}

  def update(new_value, state) do
    {event(new_value), %{state | value: new_value}}
  end

  defp event(0), do: :close
  defp event(1), do: :far
end

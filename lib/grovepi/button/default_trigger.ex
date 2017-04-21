defmodule GrovePi.Button.DefaultTrigger do
  @moduledoc """
  This is the default triggering mechanism for Button events. Events
  are either `pressed` or `released` and include the trigger state.
  The trigger state for the default trigger is a struct containing
  a `value` property.

  ## Examples

      iex> GrovePi.Button.DefaultTrigger.initial_state
      %GrovePi.Button.DefaultTrigger.State{value: 0}

      iex> GrovePi.Button.DefaultTrigger.update(0, %{value: 0})
      {:ok, %{value: 0}}

      iex> GrovePi.Button.DefaultTrigger.update(1, %{value: 1})
      {:ok, %{value: 1}}

      iex> GrovePi.Button.DefaultTrigger.update(0, %{value: 1})
      {:released, %{value: 0}}

      iex> GrovePi.Button.DefaultTrigger.update(1, %{value: 0})
      {:pressed, %{value: 1}}
  """

  defmodule State do
    @moduledoc false
    defstruct value: 0
  end

  def initial_state do
    %State{}
  end

  def update(value, %{value: value} = state), do: {:ok, state}
  def update(new_value, state) do
    {event(new_value), %{state | value: new_value}}
  end

  defp event(0), do: :released
  defp event(1), do: :pressed
end

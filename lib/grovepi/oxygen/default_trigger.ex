defmodule GrovePi.Oxygen.DefaultTrigger do
  @behaviour GrovePi.Trigger

  @moduledoc """
  This is the default triggering mechanism for Oxygen events. The
  event is `:changed` and includes the trigger state. The trigger state
  for the default trigger is a struct containing a `value` property.

  ## Examples
      iex> GrovePi.Oxygen.DefaultTrigger.init([])
      {:ok, %GrovePi.Oxygen.DefaultTrigger.State{value: 0}}

      iex> GrovePi.Oxygen.DefaultTrigger.update(0, %{value: 0})
      {:ok, %{value: 0}}

      iex> GrovePi.Oxygen.DefaultTrigger.update(500, %{value: 0})
      {:changed, %{value: 500}}

      iex> GrovePi.Oxygen.DefaultTrigger.update(500, %{value: 500})
      {:ok, %{value: 500}}

      iex> GrovePi.Oxygen.DefaultTrigger.update(125, %{value: 500})
      {:changed, %{value: 125}}
  """

  defmodule State do
    @moduledoc false
    defstruct value: 0
  end

  def init(_) do
    {:ok, %State{}}
  end

  def update(value, %{value: value} = state), do: {:ok, state}

  def update(new_value, state) do
    {:changed, %{state | value: new_value}}
  end
end

defmodule GrovePi.Ultrasonic.DefaultTrigger do
  @behaviour GrovePi.Trigger

  @moduledoc """
  This is the default triggering mechanism for changes to Ultrasonic reads. The
  event is `:changed` and includes the trigger state. The trigger state
  for the default trigger is a struct containing a `value` property.

  ## Examples
      iex> GrovePi.Ultrasonic.DefaultTrigger.init([])
      {:ok, %GrovePi.Ultrasonic.DefaultTrigger.State{value: 0}}

      iex> GrovePi.Ultrasonic.DefaultTrigger.update(50, %{value: 0})
      {:changed, %{value: 50}}

      iex> GrovePi.Ultrasonic.DefaultTrigger.update(0, %{value: 50})
      {:ok, %{value: 50}}

      iex> GrovePi.Ultrasonic.DefaultTrigger.update(125, %{value: 50})
      {:changed, %{value: 125}}

  The value 0 is an error and therefore discarded.
  """

  defmodule State do
    @moduledoc false
    defstruct value: 0
  end

  def init(_) do
    {:ok, %State{}}
  end

  def update(value, %{value: value} = state), do: {:ok, state}

  def update(value, state) when value == 0, do: {:ok, state}

  def update(new_value, state), do: {:changed, %{state | value: new_value}}
end

defmodule GrovePi.Button.DefaultTrigger do
  defmodule State do
    defstruct value: 0
  end

  def initial_state do
    %State{}
  end

  def update(value, %State{value: value} = state), do: {:ok, state}
  def update(new_value, state) do
    {event(new_value), %{state | value: new_value}}
  end

  defp event(0), do: :released
  defp event(1), do: :pressed
end

defmodule GrovePi.Sound.HysteresisTrigger do
  @moduledoc """
  This is the default triggering mechanism for Sound events. Events
  are either `pressed` or `released` and include the trigger state.
  The trigger state for the default trigger is a struct containing
  a `value` property. The lower reset threshold is 490 and the high
  reset threshold is 510.

  ## Examples
      iex> GrovePi.Sound.HysteresisTrigger.initial_state
      %GrovePi.Sound.HysteresisTrigger.State{value: 500, last_event: :none}

  ### When there has been no event

      iex> GrovePi.Sound.HysteresisTrigger.update(499, %{value: 500, last_event: :none})
      {:ok, %{value: 499, last_event: :none}}

      iex> GrovePi.Sound.HysteresisTrigger.update(489, %{value: 500, last_event: :none})
      {:quiet, %{value: 489, last_event: :quiet}}

      iex> GrovePi.Sound.HysteresisTrigger.update(511, %{value: 500, last_event: :none})
      {:loud, %{value: 511, last_event: :loud}}

  ### When the last event was loud

      iex> GrovePi.Sound.HysteresisTrigger.update(511, %{value: 500, last_event: :loud})
      {:ok, %{value: 511, last_event: :loud}}

      iex> GrovePi.Sound.HysteresisTrigger.update(501, %{value: 500, last_event: :loud})
      {:ok, %{value: 501, last_event: :loud}}

      iex> GrovePi.Sound.HysteresisTrigger.update(489, %{value: 500, last_event: :loud})
      {:quiet, %{value: 489, last_event: :quiet}}

  ### When the last event was quiet

      iex> GrovePi.Sound.HysteresisTrigger.update(470, %{value: 500, last_event: :quiet})
      {:ok, %{value: 470, last_event: :quiet}}

      iex> GrovePi.Sound.HysteresisTrigger.update(491, %{value: 500, last_event: :quiet})
      {:ok, %{value: 491, last_event: :quiet}}

      iex> GrovePi.Sound.HysteresisTrigger.update(521, %{value: 500, last_event: :quiet})
      {:loud, %{value: 521, last_event: :loud}}
  """

  defmodule State do
    @moduledoc false
    defstruct value: 500, last_event: :none
  end

  def initial_state do
    %State{}
  end

  def update(new_value, %{last_event: :none} = state) when new_value < 490 do
    {:quiet, %{state | value: new_value, last_event: :quiet}}
  end

  def update(new_value, %{last_event: :none} = state) when new_value > 510 do
    {:loud, %{state | value: new_value, last_event: :loud}}
  end

  def update(new_value, %{last_event: :loud} = state) when new_value < 490 do
    {:quiet, %{state | value: new_value, last_event: :quiet}}
  end

  def update(new_value, %{last_event: :quiet} = state) when new_value > 510 do
    {:loud, %{state | value: new_value, last_event: :loud}}
  end

  def update(new_value, state) do
    {:ok, %{state | value: new_value}}
  end
end

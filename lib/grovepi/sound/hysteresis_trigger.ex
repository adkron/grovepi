defmodule GrovePi.Sound.HysteresisTrigger do
  @behaviour GrovePi.Trigger

  @default_high_threshold 510
  @default_low_threshold 490

  @moduledoc """
  This is the default triggering mechanism for Sound events. Events
  are either `loud` or `quiet` and include the trigger state. It
  contains to thresholds a `low_threshold` and a `high_threshold` for
  triggering `loud` and `quiet` events.

  This trigger will not fire an event unless it has fired the opposite
  event or if it is the first event fired. If a `loud` event fires it
  will not be able to fire again unless a `quiet` event is fired. This
  is to keep from having a trigger float near the trigger value and
  become excessively noisy.

  ## Examples
      iex> GrovePi.Sound.HysteresisTrigger.init([])
      {:ok, %GrovePi.Sound.HysteresisTrigger.State{value: 500, fireable: :any, low_threshold: 490, high_threshold: 510}}

      iex> GrovePi.Sound.HysteresisTrigger.init(low_threshold: 10, high_threshold: 200)
      {:ok, %GrovePi.Sound.HysteresisTrigger.State{value: 500, fireable: :any, low_threshold: 10, high_threshold: 200}}

  ### When there has been no event

      iex> GrovePi.Sound.HysteresisTrigger.update(499, %{value: 500, fireable: :any, low_threshold: 490, high_threshold: 500})
      {:ok, %{value: 499, fireable: :any, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(489, %{value: 500, fireable: :any, low_threshold: 490, high_threshold: 500})
      {:quiet, %{value: 489, fireable: :loud, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(511, %{value: 500, fireable: :any, low_threshold: 490, high_threshold: 500})
      {:loud, %{value: 511, fireable: :quiet, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(21, %{value: 500, fireable: :any, low_threshold: 10, high_threshold: 20})
      {:loud, %{value: 21, fireable: :quiet, low_threshold: 10, high_threshold: 20}}

  ### When the last event was loud

      iex> GrovePi.Sound.HysteresisTrigger.update(511, %{value: 500, fireable: :quiet, low_threshold: 490, high_threshold: 500})
      {:ok, %{value: 511, fireable: :quiet, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(501, %{value: 500, fireable: :quiet, low_threshold: 490, high_threshold: 500})
      {:ok, %{value: 501, fireable: :quiet, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(489, %{value: 500, fireable: :quiet, low_threshold: 490, high_threshold: 500})
      {:quiet, %{value: 489, fireable: :loud, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(9, %{value: 500, fireable: :quiet, low_threshold: 10, high_threshold: 20})
      {:quiet, %{value: 9, fireable: :loud, low_threshold: 10, high_threshold: 20}}

  ### When the last event was quiet

      iex> GrovePi.Sound.HysteresisTrigger.update(470, %{value: 500, fireable: :loud, low_threshold: 490, high_threshold: 500})
      {:ok, %{value: 470, fireable: :loud, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(491, %{value: 500, fireable: :loud, low_threshold: 490, high_threshold: 500})
      {:ok, %{value: 491, fireable: :loud, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(521, %{value: 500, fireable: :loud, low_threshold: 490, high_threshold: 500})
      {:loud, %{value: 521, fireable: :quiet, low_threshold: 490, high_threshold: 500}}

      iex> GrovePi.Sound.HysteresisTrigger.update(21, %{value: 500, fireable: :loud, low_threshold: 10, high_threshold: 20})
      {:loud, %{value: 21, fireable: :quiet, low_threshold: 10, high_threshold: 20}}
  """

  defmodule State do
    @moduledoc false
    @enforce_keys [:high_threshold, :low_threshold]
    defstruct [
                value: 500,
                fireable: :any,
                high_threshold: nil,
                low_threshold: nil,
              ]
  end

  @doc """
  # Options

  * `:high_threshold` - The level that must be exceeded to fire a loud event, The default is `510`
  * `:low_threshold` - The level that must be recede below to fire a quiet event, The default is `490`
  """
  def init(opts) do
    high_threshold = Keyword.get(opts, :high_threshold, @default_high_threshold)
    low_threshold = Keyword.get(opts, :low_threshold, @default_low_threshold)

    {:ok, %State{high_threshold: high_threshold, low_threshold: low_threshold}}
  end

  def update(new_value, %{fireable: fireable, low_threshold: low_threshold} = state) when new_value < low_threshold and fireable != :loud do
    {:quiet, %{state | value: new_value, fireable: :loud}}
  end

  def update(new_value, %{fireable: fireable, high_threshold: high_threshold} = state) when new_value > high_threshold and fireable != :quiet do
    {:loud, %{state | value: new_value, fireable: :quiet}}
  end

  def update(new_value, state) do
    {:ok, %{state | value: new_value}}
  end
end

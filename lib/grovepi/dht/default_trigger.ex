defmodule GrovePi.DHT.DefaultTrigger do
  @behaviour GrovePi.Trigger

  @moduledoc """
  This is the default triggering mechanism for DHT events. The
  event is `:changed` and includes the trigger state. The trigger state
  for the default trigger is a struct containing `temp` and `humidity`
  properties.

  ## Examples
      iex> GrovePi.DHT.DefaultTrigger.init([])
      {:ok, %GrovePi.DHT.DefaultTrigger.State{temp: 0, humidity: 0}}
      iex> GrovePi.DHT.DefaultTrigger.update({0, 0}, %{temp: 0, humidity: 0})
      {:ok, %{temp: 0, humidity: 0}}
      iex> GrovePi.DHT.DefaultTrigger.update({11.3, 45.5}, %{temp: 0, humidity: 0})
      {:changed, %{temp: 11.3, humidity: 45.5}}
      iex> GrovePi.DHT.DefaultTrigger.update({11.3, 45.5}, %{temp: 11.3, humidity: 45.5})
      {:ok, %{temp: 11.3, humidity: 45.5}}
      iex> GrovePi.DHT.DefaultTrigger.update({22.5, 34.5}, %{temp: 11.3, humidity: 45.5})
      {:changed, %{temp: 22.5, humidity: 34.5}}
  """

  defmodule State do
    @moduledoc false
    defstruct temp: 0, humidity: 0
  end

  def init(_) do
    {:ok, %State{}}
  end

  def update({temp, humidity}, %{temp: temp, humidity: humidity} = state) do
    {:ok, state}
  end

  def update({new_temp, new_humidity}, state) do
    {:changed, %{state | temp: new_temp, humidity: new_humidity}}
  end
end

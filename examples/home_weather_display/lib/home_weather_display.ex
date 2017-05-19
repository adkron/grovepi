defmodule HomeWeatherDisplay do
  @moduledoc false
  use GenServer

  defstruct [:dht]

  alias GrovePi.{RGBLCD, DHT11}

  def start_link(pin) do
    GenServer.start_link(__MODULE__, pin)
  end

  def init([dht_pin]) do
    state = %HomeWeatherDisplay{dht: dht_pin}

    DHT11.subscribe(dht_pin, :changed)
    {:ok, state}
  end

  def handle_info({_pid, :changed, %{temp: temp, humidity: humidity}}, state) do
    text = format_text(temp, humidity)

    # Flash RGB LCD screen before change
    RGBLCD.set_rgb(0, 128, 64)
    RGBLCD.set_rgb(0, 255, 0)

    # Update LCD with new data
    RGBLCD.set_text(text)

    {:ok, state}
  end

  def handle_info(_message, state) do
    {:ok, state}
  end

  defp format_text(temp, humidity) do
    "Temp: #{Float.to_string(temp)}C  Humidity: #{Float.to_string(humidity)}%"
  end
end

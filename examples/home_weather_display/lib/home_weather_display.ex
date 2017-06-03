defmodule HomeWeatherDisplay do
  @moduledoc false
  use GenServer
  require Logger

  defstruct [:dht]

  alias GrovePi.{RGBLCD, DHT}

  def start_link(pin) do
    GenServer.start_link(__MODULE__, pin)
  end

  def init(dht_pin) do
    state = %HomeWeatherDisplay{dht: dht_pin}

    flash_rgb()
    RGBLCD.set_text("Ready!")

    DHT.subscribe(dht_pin, :changed)
    {:ok, state}
  end

  def handle_info({_pin, :changed, %{temp: temp, humidity: humidity}}, state) do
    text = format_text(temp, humidity)

    flash_rgb()

    # Update LCD with new data
    RGBLCD.set_text(text)
    Logger.info text
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp flash_rgb() do
    RGBLCD.set_rgb(0, 128, 64)
    RGBLCD.set_rgb(0, 255, 0)
  end

  defp format_text(temp, humidity) do
    "T: #{Float.to_string(temp)}C H: #{Float.to_string(humidity)}%"
  end
end

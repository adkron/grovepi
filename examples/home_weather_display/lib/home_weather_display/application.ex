defmodule HomeWeatherDisplay.Application do
  @moduledoc false
  use Application

  # RGB LCD Screen should use the IC2-1 port
  @dht_pin 7 # Use port 7 for the DHT

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the GrovePi sensor we want
      worker(GrovePi.DHT11, [@dht_pin]),

      # Start the main app
      worker(HomeWeatherDisplay, [@dht_pin]),
    ]

    opts = [strategy: :one_for_one, name: HomeWeatherDisplay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

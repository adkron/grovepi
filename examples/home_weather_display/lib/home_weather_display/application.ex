defmodule HomeWeatherDisplay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  # RGB LCD Screen should use the IC2-1 port
  # Use port 3 for the DHT
  @dht_pin 3
  # poll every 1 second
  @dht_poll_interval 1_000

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: HomeWeatherDisplay.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Starts a worker by calling: HomeWeatherDisplay.Worker.start_link(arg)
      # {HomeWeatherDisplay.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Start the GrovePi sensor we want
      worker(GrovePi.DHT, [@dht_pin, [poll_interval: @dht_poll_interval]]),

      # Start the main app
      {HomeWeatherDisplay, @dht_pin}
    ]
  end
end

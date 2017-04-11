defmodule GrovePi do
  @moduledoc """
  This application lets you interact with the [GrovePi+](https://www.dexterindustries.com/grovepi/)
  and any connected sensors in Elixir. It will automatically start with your
  application an initiate a connection to the GrovePi+ board.

  To see that everything is functioning, check the firmware version on the board.

  ```elixir
  iex> GrovePi.Board.firmware_version()
  "1.2.2"
  ```

  If this doesn't work, then nothing else will. If you're running Raspbian,
  double check that I2C is enabled in `raspi-config`.
  """

  use Application

  @grovepi_address 0x04

  @type pin :: integer

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(GrovePi.Registry.Pin, []),
      supervisor(Registry, [:duplicate, GrovePi.SubscriberRegistry], id: :subscriber_registry),

      worker(GrovePi.Board, [@grovepi_address]),
    ]

    opts = [strategy: :one_for_one, name: GrovePi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

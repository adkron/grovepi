defmodule GrovePi do
  @moduledoc """
  Low-level interface for sending raw requests and receiving responses from a
  GrovePi hat. Create one of these first and then use one of the other GrovePi
  modules for interacting with a connected sensor, light, or actuator.

  To check that your GrovePi hardware is working, try this:

  ```
  iex> {:ok, pid}=GrovePi.start_link()
  {:ok, #PID<0.212.0>}
  iex> GrovePi.firmware_version(pid)
  "1.2.2"
  ```
  """

  use Application

  @grovepi_address 0x04

  @type pin :: integer

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, GrovePi.PinRegistry], id: :pin_registry),
      supervisor(Registry, [:duplicate, GrovePi.SubscriberRegistry], id: :subscriber_registry),

      worker(GrovePi.Board, [@grovepi_address]),
    ]

    opts = [strategy: :one_for_one, name: GrovePi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

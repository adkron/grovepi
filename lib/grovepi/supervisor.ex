defmodule GrovePi.Supervisor do
  use Supervisor

  def start_link(grovepi_address, prefix) do
    Supervisor.start_link(__MODULE__, [grovepi_address, prefix])
  end

  def init([grovepi_address, prefix]) do
    children = [
      supervisor(GrovePi.Registry.Pin, [prefix]),
      supervisor(GrovePi.Registry.Subscriber, [prefix]),

      worker(GrovePi.Board, [grovepi_address, prefix]),
    ]

    supervise children, strategy: :one_for_one, name: name(prefix)
  end

  defp name(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end
end

defmodule GrovePi.Supervisor do
  use Supervisor

  def start_link(grovepi_address, prefix) do
    Supervisor.start_link(__MODULE__, [grovepi_address, prefix])
  end

  def init([grovepi_address, prefix]) do
    children = [
      supervisor(GrovePi.Registry.Pin, []),
      supervisor(GrovePi.Registry.Subscriber, []),

      worker(GrovePi.Board, [grovepi_address]),
    ]

    supervise children, strategy: :one_for_one, name: name(prefix)
  end

  defp name(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end
end

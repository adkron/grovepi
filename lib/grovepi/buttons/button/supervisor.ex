defmodule GrovePi.Button.Supervisor do
  use Supervisor

  @spec start_link(pid, GrovePi.Buttons.pin) :: Supervisor.on_start
  def start_link(grove_pid, pin) do
    Supervisor.start_link(__MODULE__, [grove_pid, pin])
  end

  def init([grove_pid, pin]) do
    children = [
      worker(GrovePi.Button.Handler, [grove_pid, pin])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

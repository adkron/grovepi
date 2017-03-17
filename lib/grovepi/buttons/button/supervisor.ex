defmodule GrovePi.Button.Supervisor do
  use Supervisor

  def start_link(grove_pid, pin) do
    Supervisor.start_link(__MODULE__, [grove_pid, pin])
  end

  def init([grove_pid, pin]) do
    children = [
      worker(GrovePi.Button.Handler, [self(), grove_pid, pin])
    ]

    supervise(children, strategy: :one_for_rest)
  end

  def start_poller(sup_pid, handler_pid) do
    Supervisor.start_child(sup_pid, worker(GrovePi.Button.Poller, [handler_pid]))
  end
end

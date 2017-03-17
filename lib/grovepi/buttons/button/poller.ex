defmodule GrovePi.Button.Poller do
  def start_link(handler_pid) do
    Task.start_link(fn -> poll(handler_pid) end)
  end

  def poll(handler_pid) do
    :timer.sleep 100
    GrovePi.Button.Handler.notify_state(handler_pid)
    loop(handler_pid)
  end
end

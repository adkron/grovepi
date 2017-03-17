defmodule GrovePi.Buttons do
  def start_link(grove_pi_pid) do
    with {:ok, _} <- GrovePi.Buttons.Supervisor.start_link(grove_pi_pid),
         {:ok, _} <- GrovePi.Buttons.Registry.start_link,
         do: :ok
  end

  def add(pin) do
    GrovePi.Buttons.Supervisor.add(pin)
  end

  def register(event, pin) do
    GrovePi.Buttons.Registry.register({event, pin})
  end

  def notify_change(pin, last_value, 1) when last_value != 1 do
    IO.puts "pressed"
    GrovePi.Buttons.Registry.dispatch({:pressed, pin})
  end

  def notify_change(pin, last_value, 0) when last_value != 0 do
    IO.puts "released"
    GrovePi.Buttons.Registry.dispatch({:released, pin})
  end

  def notify_change(_pin, current_value, current_value), do: :ok
end

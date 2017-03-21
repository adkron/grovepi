defmodule GrovePi.Buttons do

  @type event :: :pressed | :released
  @type pin :: integer
  @type message :: {event, pin}

  @spec start_link(pid) :: Supervisor.on_start
  def start_link(grove_pi_pid) do
    with {:ok, _} <- GrovePi.Buttons.Supervisor.start_link(grove_pi_pid),
         {:ok, _} <- GrovePi.Buttons.Registry.start_link,
         do: :ok
  end

  @spec add(pin) :: Supervisor.on_start
  def add(pin) do
    GrovePi.Buttons.Supervisor.add(pin)
  end

  @spec register(message) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register({event, pin}) do
    GrovePi.Buttons.Registry.register({event, pin})
  end

  @spec notify_change(pin, GrovePi.Button.Handler.change) :: :ok
  def notify_change(pin, {last_value, 1}) when last_value != 1 do
    GrovePi.Buttons.Registry.dispatch({:pressed, pin})
  end

  def notify_change(pin, {last_value, 0}) when last_value != 0 do
    GrovePi.Buttons.Registry.dispatch({:released, pin})
  end

  def notify_change(_pin, {current_value, current_value}), do: :ok
end

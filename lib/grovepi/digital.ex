defmodule GrovePi.Digital do
  @moduledoc """
  Write to and read digital I/O on the GrovePi.

  Example usage:
  ```
  iex> {:ok, pid}=GrovePi.start_link
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Digital.set_pin_mode(pid, 3, :output)
  :ok
  iex> GrovePi.Digital.write(pid, 3, 1)
  :ok
  iex> GrovePi.Digital.write(pid, 3, 0)
  :ok
  ```

  """

  def set_pin_mode(pid, pin, pin_mode) do
    GrovePi.send_request(pid, <<5, pin, mode(pin_mode), 0>>)
  end

  def read(pid, pin) do
    :ok = GrovePi.send_request(pid, <<1, pin, 0, 0>>)
    <<value>> = GrovePi.get_response(pid, 1)
    value
  end

  def write(pid, pin, value) when value == 0 or value == 1 do
    GrovePi.send_request(pid, <<2, pin, value, 0>>)
  end

  defp mode(:input), do: 0
  defp mode(:output), do: 1
end

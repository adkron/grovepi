defmodule GrovePi.Analog do
  @moduledoc """
  Write to and read analog I/O on the GrovePi.

  Example use:

  iex> {:ok, pid}=GrovePi.start_link
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Analog.read(pid, 0)
  971
  iex> GrovePi.Analog.read(pid, 0)
  400

  """

  def read(pid, pin) do
    :ok = GrovePi.send_request(pid, <<3, pin, 0, 0>>)
    <<_, value::size(16)>> = GrovePi.get_response(pid, 3)
    value
  end

  def write(pid, pin, value) do
    GrovePi.send_request(pid, <<4, pin, value, 0>>)
  end

end

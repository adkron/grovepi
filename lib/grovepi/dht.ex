defmodule GrovePi.DHT do
  @moduledoc """
  Read temperature and humidity from the Grove DHT sensor.

  Example use:

  iex> {:ok, pid}=GrovePi.start_link
  {:ok, #PID<0.199.0>}
  iex> GrovePi.DHT.read_temp_and_humidity(pid, 2)
  {23.0, 40.0}

  """

  def read_temp_and_humidity(pid, pin, module_type \\ 0) do
    :ok = GrovePi.send_request(pid, <<40, pin, module_type, 0>>)
    <<_, temp::little-float-size(32), humidity::little-float-size(32)>> =
      GrovePi.get_response(pid, 9)
    {temp, humidity}
  end
end

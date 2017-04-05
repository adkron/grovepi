defmodule GrovePi.DHT do
  @moduledoc """
  Read temperature and humidity from the Grove DHT sensor.

  Example use:

  ```
  iex> pin = 3
  iex> {:ok, pid}=GrovePi.DHT.start_link(pin)
  {:ok, #PID<0.199.0>}
  iex> GrovePi.DHT.read_temp_and_humidity(pin)
  {23.0, 40.0}
  ```

  """

  @type temp :: float
  @type humidity :: float
  @type module_type :: integer

  alias GrovePi.Utils

  defmodule State do
    @moduledoc false
    defstruct [:pin]
  end

  @spec start_link(GrovePi.pin) :: Supervisor.on_start
  def start_link(pin, opts \\ []) do
    opts = Keyword.put(opts, :name, Utils.pin_name(pin))
    GenServer.start_link(__MODULE__, [pin], opts)
  end

  def init([pin]) do
    {:ok, %State{pin: pin}}
  end

  @spec read_temp_and_humidity(GrovePi.pin) :: {temp, humidity}
  @spec read_temp_and_humidity(GrovePi.pin, module_type) :: {temp, humidity}
  def read_temp_and_humidity(pin, module_type \\ 0) do
    GenServer.call(Utils.pin_name(pin), {:read_temp_and_humidity, module_type})
  end

  def handle_call({:read_temp_and_humidity, module_type}, _from, state) do
    :ok = GrovePi.Board.send_request(<<40, state.pin, module_type, 0>>)
    <<_, temp::little-float-size(32), humidity::little-float-size(32)>> =
      GrovePi.Board.get_response(9)
      {:reply, {temp, humidity}, state}
  end
end

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

  alias GrovePi.Registry.Pin

  defmodule State do
    @moduledoc false
    defstruct [:pin, :prefix]
  end

  @spec start_link(GrovePi.pin, atom) :: Supervisor.on_start
  def start_link(pin, opts \\ []) do
    prefix = Keyword.get(opts, :prefix, Default)
    opts = Keyword.put(opts, :name, Pin.name(prefix, pin))
    GenServer.start_link(__MODULE__, [pin, prefix], opts)
  end

  def init([pin, prefix]) do
    {:ok, %State{pin: pin, prefix: prefix}}
  end

  @spec read_temp_and_humidity(GrovePi.pin, atom, module_type) :: {temp, humidity}
  def read_temp_and_humidity(pin, prefix \\ Default, module_type \\ 0) do
    GenServer.call(Pin.name(prefix, pin), {:read_temp_and_humidity, module_type})
  end

  def handle_call({:read_temp_and_humidity, module_type}, _from, state) do
    :ok = GrovePi.Board.send_request(state.prefix, <<40, state.pin, module_type, 0>>)
    <<_, temp::little-float-size(32), humidity::little-float-size(32)>> =
      GrovePi.Board.get_response(state.prefix, 9)
      {:reply, {temp, humidity}, state}
  end
end

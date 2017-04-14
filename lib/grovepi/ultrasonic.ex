defmodule GrovePi.Ultrasonic do
  @moduledoc """
  Read distance from the Grove Ultrasonic sensor.

  Example use:
  ```
  iex> pin = 3
  iex> {:ok, pid}=GrovePi.Ultrasonic.start_link(pin)
  {:ok, #PID<0.205.0>}
  iex> GrovePi.Ultrasonic.read_distance(pin)
  20
  iex> GrovePi.Ultrasonic.read_distance(pin)
  23
  ```
  """

  @type distance :: integer

  alias GrovePi.Board
  alias GrovePi.Registry.Pin

  defmodule State do
    @moduledoc false
    defstruct [:pin, :prefix]
  end

  @spec start_link(GrovePi.pin) :: Supervisor.on_start
  def start_link(pin, opts \\ []) do
    prefix = Keyword.get(opts, :prefix, Default)
    opts = Keyword.put(opts, :name, Pin.name(prefix, pin))
    GenServer.start_link(__MODULE__, [pin, prefix], opts)
  end

  def init([pin, prefix]) do
    {:ok, %State{pin: pin, prefix: prefix}}
  end

  @spec read_distance(GrovePi.pin, atom) :: distance
  def read_distance(pin, prefix \\ Default) do
    GenServer.call(Pin.name(prefix, pin), {:read_distance})
  end

  def handle_call({:read_distance}, _from, state) do
    with :ok <- Board.send_request(state.prefix, <<7, state.pin, 0, 0>>),
         # Firmware waits for 50 ms to read sensor
         :ok <- Process.sleep(60),
         <<_, distance::big-integer-size(16)>> <- Board.get_response(state.prefix, 3),
         do: {:reply, distance, state}
  end

end

defmodule GrovePi.Button.Handler do
  use GenServer

  @type level :: 1 | 0
  @type change :: {level, level}

  defmodule State do
    defstruct [:pin, :grove, :value]
  end

  @spec start_link(pid, pid, GrovePi.Buttons.pin) :: Supervisor.on_start
  def start_link(sup_pid, grove, pin) do
    GenServer.start_link(__MODULE__, [sup_pid, grove, pin])
  end

  def init([sup_pid, grove, pin]) do
    state = %State{pin: pin, grove: grove}
            |> update_value()

    pid = self()

    Task.start fn ->
      GrovePi.Button.Supervisor.start_poller(sup_pid, pid)
    end

    {:ok, state}
  end

  @spec notify_state(GenServer.server) :: :ok
  def notify_state(server) do
    GenServer.cast(server, {:notify_state})
  end

  @spec read(GenServer.server) :: level
  def read(server) do
    GenServer.call(server, {:read})
  end

  def handle_cast({:notify_state}, state) do
    new_state = update_value(state)
    {:noreply, new_state}
  end

  def handle_call({:read}, _from, state) do
    new_state = update_value(state)
    {:reply, new_state.value, state}
  end

  @spec update_value(State) ::State
  def update_value(state) do
    new_value = GrovePi.Digital.read(state.grove, state.pin)
    GrovePi.Buttons.notify_change(state.pin, {state.value, new_value})
    %{state | value: new_value}
  end
end

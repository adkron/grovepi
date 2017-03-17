defmodule GrovePi.Button.Handler do
  use GenServer

  defmodule State do
    defstruct [:pin, :grove, :value]
  end

  def start_link(sup_pid, grove, pin) do
    GenServer.start_link(__MODULE__, [sup_pid, grove, pin])
  end

  def init([sup_pid, grove, pin]) do
    state = %State{pin: pin, grove: grove}
    pid = self()

    Task.start fn ->
      GrovePi.Button.start_poller(sup_pid, pid)
    end

    {:ok, state}
  end

  def notify_state(pid) do
    GenServer.cast(pid, {:notify_state})
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  def handle_cast({:notify_state}, state) do
    new_state = update_value(state)
    {:noreply, new_state}
  end

  def handle_call({:read}, _from, state) do
    new_state = update_value(state)
    {:reply, new_state.value, state}
  end

  def update_value(state) do
    new_value = GrovePi.Digital.read(state.grove, state.pin)
    GrovePi.Buttons.notify_change(state.value, new_value)
     %{state | value: value}
  end
end

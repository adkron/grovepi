defmodule GrovePi.Button do
  use GenServer

  @type level :: 1 | 0
  @type change :: {level, level}

  @poll_interval 100

  defmodule State do
    @moduledoc false
    defstruct [:pin, :grove, :value]
  end

  @spec start_link(pid, GrovePi.Buttons.pin) :: Supervisor.on_start
  def start_link(grove, pin) do
    GenServer.start_link(__MODULE__, [grove, pin])
  end

  def init([grove, pin]) do
    state = %State{pin: pin, grove: grove}
            |> update_value()

    {:ok, _} = :timer.send_interval(@poll_interval, :poll_button)

    {:ok, state}
  end

  @spec read(GenServer.server) :: level
  def read(server) do
    GenServer.call(server, {:read})
  end

  def handle_call({:read}, _from, state) do
    new_state = update_value(state)
    {:reply, new_state.value, state}
  end

  def handle_info(:poll_button, state) do
    new_state = update_value(state)
    {:noreply, new_state}
  end

  @spec update_value(State) ::State
  def update_value(state) do
    new_value = GrovePi.Digital.read(state.grove, state.pin)
    GrovePi.Buttons.notify_change(state.pin, {state.value, new_value})
    %{state | value: new_value}
  end
end

require IEx
defmodule GrovePi.Button do
  use Supervisor
  @moduledoc """
  Listen for the state of a button and send notification of change

  Example usage:

  iex> {:ok, grove_pid}=GrovePi.start_link
  iex> {:ok, pid} = GrovePi.Button.start_link(grove_pid, pin)

  repleased
  iex> GrovePi.Button.read(pid)
  0

  pressed
  iex> GrovePi.Button.read(pid)
  1

  iex> GrovePi.Button.add_listenter(pid, :pressed, module)
  {:ok, _}

  iex> GrovePi.Button.add_listenter(pid, :released, module)
  {:ok, _}
  """

  def start_link(grove_pid, pin) do
    Supervisor.start_link(__MODULE__, [grove_pid, pin])
  end

  def init([grove_pid, pin]) do
    children = [
      worker(GrovePi.Button.Handler, [self(), grove_pid, pin])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def start_loop(sup_pid, handler_pid) do
    Supervisor.start_child(sup_pid, worker(GrovePi.Button.Loop, [handler_pid]))
  end

  defmodule Loop do
    def start_link(handler_pid) do
      Task.start_link(fn -> loop(handler_pid) end)
    end

    def loop(handler_pid) do
      :timer.sleep 1000
      GrovePi.Button.Handler.notify_state(handler_pid)
      loop(handler_pid)
    end

  end

  defmodule Handler do
    use GenServer
    defmodule State do
      defstruct [:pin, :registry, :grove, :sup_pid, :value]
    end

    def start_link(sup_pid, grove, pin) do
      GenServer.start_link(__MODULE__, [sup_pid, grove, pin])
    end

    def init([sup_pid, grove, pin]) do
      #{:ok, pid} = Registry.start_link(:duplicate)
      state = %State{pin: pin, registry: nil, grove: grove, sup_pid: sup_pid}
      handler_pid = self()
      Task.start fn -> GrovePi.Button.start_loop(sup_pid, handler_pid) end
      {:ok, state}
    end

    def notify_state(pid) do
      GenServer.cast(pid, {:notify_state})
    end

    def notify_change(1, 0), do: IO.puts "released"
    def notify_change(0, 1), do: IO.puts "pressed"
    def notify_change(_, _), do: :ok

    def handle_cast({:notify_state}, state) do
      new_state = update_value(state)
      notify_change(state.value, new_state.value)
      {:noreply, new_state}
    end

    def read(pid) do
      GenServer.call(pid, {:read})
    end

    def handle_call({:read}, _from, state) do
      new_state = update_value(state)
      {:reply, new_state.value, new_state}
    end

    def update_value(state) do
      value = GrovePi.Digital.read(state.grove, state.pin)
      %{state | value: value}
    end
  end
end

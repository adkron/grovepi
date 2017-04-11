defmodule GrovePi.Button do
  use GenServer

  @moduledoc """
  Listen for events from a GrovePi button. There are two types of
  events; pressed and released. When registering for an event the button
  will then send a message of `{pin, :pressed}` or `{pin, :released}`.
  The button works by polling `GrovePi.Digital` on the pin that you have
  registered to a button.

  Example usage:
  ```
  iex> {:ok, button}=GrovePi.Button.start_link(3)
  :ok
  iex> GrovePi.Button.subscribe(3, :pressed)
  :ok
  iex> GrovePi.Button.subscribe(3, :released)
  :ok
  ```
  """

  @type level :: 1 | 0
  @type change :: {level, level}
  @type event :: :pressed | :released

  @poll_interval 100

  alias GrovePi.Registry.Pin
  @pin_registry Pin

  alias GrovePi.Registry.Subscriber

  defmodule State do
    @moduledoc false
    defstruct [:pin, :value, :poll_interval]
  end

  @spec start_link(GrovePi.pin) :: Supervisor.on_start
  def start_link(pin, opts \\ []) do
    poll_interval = Keyword.get(opts, :poll_interval, @poll_interval)
    pin_registry = Keyword.get(opts, :pin_registry, @pin_registry)
    pin_registry = Keyword.get(opts, :pin_registry, @pin_registry)
    opts = Keyword.put(opts, :name, Pin.name(pin_registry, pin))

    GenServer.start_link(__MODULE__,
      [pin, poll_interval],
      opts
      )
  end

  def init([pin, poll_interval]) do
    state = %State{
      pin: pin,
      poll_interval: poll_interval,
      }
            |> update_value()

    schedule_poll(state)

    {:ok, state}
  end

  def schedule_poll(%State{poll_interval: poll_interval}) do
    Process.send_after(self(), :poll_button, poll_interval)
  end

  @spec read(GrovePi.pin) :: level
  def read(pin, pin_registry \\ @pin_registry) do
    GenServer.call(Pin.name(pin_registry, pin), :read)
  end

  @spec subscribe(GrovePi.pin, event) :: level
  def subscribe(pin, event) do
    Subscriber.subscribe({pin, event})
  end

  def handle_call(:read, _from, state) do
    new_state = update_value(state)
    {:reply, new_state.value, new_state}
  end

  def handle_info(:poll_button, state) do
    new_state = update_value(state)
    schedule_poll(state)
    {:noreply, new_state}
  end

  @spec update_value(State) ::State
  def update_value(state) do
    new_value = GrovePi.Digital.read(state.pin)
    update_value(state, state.value, new_value)
  end

  defp update_value(state, value, value), do: state
  defp update_value(state, _old_value, new_value) do
    Subscriber.notify_change({state.pin, event(new_value)})
    %{state | value: new_value}
  end

  defp event(0), do: :released
  defp event(1), do: :pressed
end

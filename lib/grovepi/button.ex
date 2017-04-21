defmodule GrovePi.Button do
  use GenServer

  @moduledoc """
  Listen for events from a GrovePi button. There are two types of
  events; pressed and released. When registering for an event the button
  will then send a message of `{pin, :pressed, {value: 1}` or
  `{pin, :released, {value: 0}}`. The button works by polling
  `GrovePi.Digital` on the pin that you have registered to a button.

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
  @trigger GrovePi.Button.DefaultTrigger

  alias GrovePi.Registry.Pin

  alias GrovePi.Registry.Subscriber

  defmodule State do
    @moduledoc false
    defstruct [:pin, :trigger_state, :poll_interval, :prefix, :trigger]
  end

  @spec start_link(GrovePi.pin) :: Supervisor.on_start
  def start_link(pin, opts \\ []) do
    poll_interval = Keyword.get(opts, :poll_interval, @poll_interval)
    trigger = Keyword.get(opts, :trigger, @trigger)
    prefix = Keyword.get(opts, :prefix, Default)
    opts = Keyword.put(opts, :name, Pin.name(prefix, pin))

    GenServer.start_link(__MODULE__,
      [pin, poll_interval, prefix, trigger],
      opts
      )
  end

  def init([pin, poll_interval, prefix, trigger]) do
    state = %State{
      pin: pin,
      poll_interval: poll_interval,
      prefix: prefix,
      trigger: trigger,
      trigger_state: trigger.initial_state,
      }

    schedule_poll(state)

    {:ok, state}
  end

  def schedule_poll(%State{poll_interval: poll_interval}) do
    Process.send_after(self(), :poll_button, poll_interval)
  end

  @spec read(GrovePi.pin, atom) :: level
  def read(pin, prefix \\ Default) do
    GenServer.call(Pin.name(prefix, pin), :read)
  end

  @spec subscribe(GrovePi.pin, event, atom) :: level
  def subscribe(pin, event, prefix \\ Default) do
    Subscriber.subscribe(prefix, {pin, event})
  end

  def handle_call(:read, _from, state) do
    {value, new_state} = update_value(state)
    {:reply, value, new_state}
  end

  def handle_info(:poll_button, state) do
    {_, new_state} = update_value(state)
    schedule_poll(state)
    {:noreply, new_state}
  end

  @spec update_value(State) ::State
  defp update_value(state) do
    with value <- GrovePi.Digital.read(state.prefix, state.pin),
         trigger = {_, trigger_state} <- state.trigger.update(value, state.trigger_state),
         :ok <- notify(trigger, state.prefix, state.pin),
         do: {value, %{state | trigger_state: trigger_state}}
  end

  defp notify({:ok, _}, _, _) do
    :ok
  end

  defp notify({event, trigger_state}, prefix, pin) do
    Subscriber.notify_change(prefix, {pin, event, trigger_state})
  end
end

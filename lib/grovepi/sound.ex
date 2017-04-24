defmodule GrovePi.Sound do
  use GenServer

  @moduledoc """
  Listen for events from a GrovePi sound. There are two types of
  events; loud and quiet. When registering for an event the sound
  will then send a message of `{pin, :loud, {value: 1, last_event: :loud}` or
  `{pin, :quiet, {value: 0, last_event: :quiet}}`. The sound works by polling
  `GrovePi.Digital` on the pin that you have registered to a sound.

  Example usage:
  ```
  iex> {:ok, sound}=GrovePi.Sound.start_link(3)
  :ok
  iex> GrovePi.Sound.subscribe(3, :loud)
  :ok
  iex> GrovePi.Sound.subscribe(3, :quiet)
  :ok
  ```
  """

  @type level :: 1 | 0
  @type change :: {level, level}
  @type event :: :loud | :quiet

  @poll_interval 100
  @trigger GrovePi.Sound.HysteresisTrigger

  alias GrovePi.Registry.Pin

  alias GrovePi.Registry.Subscriber

  defmodule State do
    @moduledoc false
    defstruct [:pin, :trigger_state, :poll_interval, :prefix, :trigger]
  end

  @doc """
  # Options

    * `:poll_interval` - The time in ms between polling for state. Default: `100`
    * `:trigger` - This is used to pass in a trigger to use for triggering events. Default: `GrovePi.Sound.HyseresisTrigger`
  """

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
    Process.send_after(self(), :poll_sound, poll_interval)
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

  def handle_info(:poll_sound, state) do
    {_, new_state} = update_value(state)
    schedule_poll(state)
    {:noreply, new_state}
  end

  @spec update_value(State) ::State
  defp update_value(state) do
    with value <- GrovePi.Analog.read(state.prefix, state.pin),
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

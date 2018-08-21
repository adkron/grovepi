defmodule GrovePi.Poller do
  @moduledoc """
  A behaviour module for implementing polling on a pin.

  The GrovePi.Poller behavior abstracts polling on a pin.  Developers are
  responsible for implementing `c:read_value/2` and a module using the
  `GrovePi.Trigger` behaviour.

  ## Example

  This example shows implementation of `GrovePi.Potentiometer`.  The module
  should `use GrovePi.Poller`, specifiying the `:default_trigger` and
  `:read_type`.  It should have a `c:read_value/2` callback which reads the
  desired sensor.

      defmodule GrovePi.Potentiometer do
        alias GrovePi.Analog

        use GrovePi.Poller, default_trigger: GrovePi.Potentiometer.DefaultTrigger,
          read_type: Analog.adc_level

        def read_value(prefix, pin) do
          Analog.read(prefix, pin)
        end
      end

  The requirements for creating the `:default_trigger` are described in
  `GrovePi.Trigger`.
  """

  @callback read_value(atom, GrovePi.pin()) :: any

  defmacro __using__(default_trigger: default_trigger, read_type: read_type) do
    quote location: :keep do
      use GenServer
      @behaviour GrovePi.Poller

      @poll_interval 100

      alias GrovePi.Registry.Pin

      alias GrovePi.Registry.Subscriber

      defmodule State do
        @moduledoc false
        defstruct [:pin, :trigger_state, :poll_interval, :prefix, :trigger, :poll_reference]

        def poll(%State{poll_interval: 0} = state, pid) do
          state
        end

        def poll(%State{poll_interval: poll_interval} = state, pid) do
          reference = Process.send_after(pid, :poll_button, poll_interval)
          %{state | poll_reference: reference}
        end

        def cancel_polling(%State{poll_reference: reference} = state) do
          Process.cancel_timer(reference)
          %{state | poll_reference: nil}
        end

        def change_interval(state, interval) do
          %{state | poll_interval: interval}
        end
      end

      @doc """
      Starts a process linked to the current process.

      This is often used to start the process as part of a supervision tree.

      ## Options

      * `:poll_interval` - The time in ms between polling for state.i If set to 0
                           polling will be turned off. Default: `100`
      * `:trigger` - This is used to pass in a trigger to use for triggering
                     events. See specific poller for defaults
      * `:trigger_opts` - This is used to pass options to a trigger `init\1`. The default is `[]`
      """

      @spec start_link(GrovePi.pin()) :: Supervisor.on_start()
      def start_link(pin, opts \\ []) do
        poll_interval = Keyword.get(opts, :poll_interval, @poll_interval)
        trigger = Keyword.get(opts, :trigger, unquote(default_trigger))
        trigger_opts = Keyword.get(opts, :trigger_opts, [])
        prefix = Keyword.get(opts, :prefix, Default)
        opts = Keyword.put(opts, :name, Pin.name(prefix, pin))

        GenServer.start_link(
          __MODULE__,
          [pin, poll_interval, prefix, trigger, trigger_opts],
          opts
        )
      end

      def init([pin, poll_interval, prefix, trigger, trigger_opts]) do
        {:ok, trigger_state} = trigger.init(trigger_opts)

        state = %State{
          pin: pin,
          poll_interval: poll_interval,
          prefix: prefix,
          trigger: trigger,
          trigger_state: trigger_state
        }

        state_with_poll_reference = schedule_poll(state)

        {:ok, state_with_poll_reference}
      end

      @doc """
      Stops polling immediately
      """
      @spec stop_polling(GrovePi.pin(), atom) :: :ok
      def stop_polling(pin, prefix \\ Default) do
        GenServer.cast(Pin.name(prefix, pin), {:change_polling, 0})
      end

      @doc """
      Stops the current scheduled polling event and starts a new one with
      the new interval.
      """
      @spec change_polling(GrovePi.pin(), integer, atom) :: :ok
      def change_polling(pin, interval, prefix \\ Default) do
        GenServer.cast(Pin.name(prefix, pin), {:change_polling, interval})
      end

      @doc """
      Read the value from the specified pin.
      """
      @spec read(GrovePi.pin(), atom) :: unquote(read_type)
      def read(pin, prefix \\ Default) do
        GenServer.call(Pin.name(prefix, pin), :read)
      end

      @doc """
      Subscribes the current process to an event.
      """
      @spec subscribe(GrovePi.pin(), GrovePi.Trigger.event(), atom) ::
              {:ok, pid} | {:error, {:already_registered, pid}}
      def subscribe(pin, event, prefix \\ Default) do
        Subscriber.subscribe(prefix, {pin, event})
      end

      def handle_cast({:change_polling, interval}, state) do
        new_state =
          state
          |> State.cancel_polling()
          |> State.change_interval(interval)
          |> State.poll(self())

        {:noreply, new_state}
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

      @spec update_value(State) :: State
      defp update_value(state) do
        with value <- read_value(state.prefix, state.pin),
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

      defp schedule_poll(state) do
        State.poll(state, self())
      end
    end
  end
end

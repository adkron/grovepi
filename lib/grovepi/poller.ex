defmodule GrovePi.Poller do
  @callback read_value(atom, GrovePi.pin) :: any

  defmacro __using__([default_trigger: default_trigger, read_type: read_type]) do
    quote location: :keep do
      use GenServer
      @behaviour GrovePi.Poller

      @poll_interval 100

      @type event :: atom

      alias GrovePi.Registry.Pin

      alias GrovePi.Registry.Subscriber

      defmodule State do
        @moduledoc false
        defstruct [:pin, :trigger_state, :poll_interval, :prefix, :trigger]
      end

      @doc """
      # Options

      * `:poll_interval` - The time in ms between polling for state. Default: `100`
      * `:trigger` - This is used to pass in a trigger to use for triggering events. Default: `GrovePi.Button.DefaultTrigger`
      """

      @spec start_link(GrovePi.pin) :: Supervisor.on_start
      def start_link(pin, opts \\ []) do
        poll_interval = Keyword.get(opts, :poll_interval, @poll_interval)
        trigger = Keyword.get(opts, :trigger, unquote(default_trigger))
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

      @spec read(GrovePi.pin, atom) :: unquote(read_type)
      def read(pin, prefix \\ Default) do
        GenServer.call(Pin.name(prefix, pin), :read)
      end

      @spec subscribe(GrovePi.pin, event, atom) :: {:ok, pid} | {:error, {:already_registered, pid}}
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
    end
  end
end

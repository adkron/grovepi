defmodule GrovePi.Buzzer do
  @moduledoc """
  Control a Grove buzzer. While a buzzer can be controlled solely using
  `GrovePi.Digital`, this module provides some helpers.

  Example usage:
  ```
  iex> {:ok, buzzer} = GrovePi.Buzzer.start_link(3)
  :ok
  iex> GrovePi.Buzzer.buzz(3)
  :ok
  ```
  """

  use GenServer

  @type duration :: integer

  alias GrovePi.Digital
  alias GrovePi.Registry.Pin

  defmodule State do
    @moduledoc false
    defstruct [:pin, :turnoff_time, :prefix]
  end

  @spec start_link(GrovePi.pin(), atom) :: Supervisor.on_start()
  def start_link(pin, opts \\ []) do
    prefix = Keyword.get(opts, :prefix, Default)
    opts = Keyword.put(opts, :name, Pin.name(prefix, pin))

    GenServer.start_link(__MODULE__, [pin, prefix], opts)
  end

  @spec buzz(GrovePi.pin(), duration, atom) :: :ok
  def buzz(pin, duration, prefix) do
    GenServer.cast(Pin.name(prefix, pin), {:buzz, duration})
  end

  def buzz(pin, duration_or_prefix) when is_atom(duration_or_prefix) do
    buzz(pin, 1000, duration_or_prefix)
  end

  def buzz(pin, duration_or_prefix) when is_integer(duration_or_prefix) do
    buzz(pin, duration_or_prefix, Default)
  end

  @spec off(GrovePi.pin()) :: :ok
  def off(pin, prefix \\ Default) do
    GenServer.cast(Pin.name(prefix, pin), :off)
  end

  def init([pin, prefix]) do
    state = %State{pin: pin, prefix: prefix}

    send(self(), :setup_pin)

    {:ok, state}
  end

  def handle_cast(:off, state) do
    :ok = Digital.write(state.prefix, state.pin, 0)
    {:noreply, state}
  end

  def handle_cast({:buzz, duration}, state) do
    turnoff_at = System.monotonic_time(:millisecond) + duration
    new_state = %{state | turnoff_time: turnoff_at}

    :ok = Digital.write(state.prefix, state.pin, 1)
    :timer.send_after(duration, self(), :timeout)

    {:noreply, new_state}
  end

  def handle_info(:setup_pin, state) do
    # Turn off the buzzer on initialization just in case it happens to be
    # on from a previous crash.
    :ok = Digital.set_pin_mode(state.prefix, state.pin, :output)
    :ok = Digital.write(state.prefix, state.pin, 0)
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    if System.monotonic_time(:millisecond) >= state.turnoff_time do
      :ok = Digital.write(state.prefix, state.pin, 0)
    end

    {:noreply, state}
  end
end

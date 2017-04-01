defmodule GrovePi.Buzzer do

  @moduledoc """
  Control a Grove buzzer. While a buzzer can be controlled solely using
  `GrovePi.Digital`, this module provides some helpers.

  Example usage:
  ```
  iex> {:ok, grovepi}=GrovePi.start_link
  {:ok, #PID<0.205.0>}
  iex> {:ok, buzzer}=GrovePi.Buzzer.start_link(grovepi, 3)
  :ok
  iex> GrovePi.Buzzer.buzz(buzzer)
  :ok
  ```
  """

  use GenServer

  alias GrovePi.Utils

  defmodule State do
    @moduledoc false
    defstruct [:pin,
               :turnoff_time]
  end

  def start_link(pin, opts \\ []) do
    opts = Keyword.put(opts, :name, Utils.pin_name(pin))

    GenServer.start_link(__MODULE__, [pin], opts)
  end

  def buzz(pin, duration \\ 1000) do
    GenServer.cast(Utils.pin_name(pin), {:buzz, duration})
  end

  def off(pin) do
    GenServer.cast(Utils.pin_name(pin), :off)
  end

  def init([pin]) do
    state = %State{pin: pin}

    send(self(), :setup_pin)

    {:ok, state}
  end

  def handle_cast(:off, state) do
    :ok = GrovePi.Digital.write(state.pin, 0)
    {:noreply, state}
  end
  def handle_cast({:buzz, duration}, state) do
    turnoff_at = System.monotonic_time(:millisecond) + duration
    new_state = %{state | turnoff_time: turnoff_at}

    :ok = GrovePi.Digital.write(state.pin, 1)
    :timer.send_after(duration, self(), :timeout)

    {:noreply, new_state}
  end

  def handle_info(:setup_pin, state) do
    # Turn off the buzzer on initialization just in case it happens to be
    # on from a previous crash.
    :ok = GrovePi.Digital.set_pin_mode(state.pin, :output)
    :ok = GrovePi.Digital.write(state.pin, 0)
    {:noreply, state}
  end
  def handle_info(:timeout, state) do
    if System.monotonic_time(:millisecond) >= state.turnoff_time do
      :ok = GrovePi.Digital.write(state.pin, 0)
    end
    {:noreply, state}
  end
end

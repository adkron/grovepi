defmodule Alarm.Worker do
  @moduledoc false
  use GenServer

  # Pick ports that work on both the GrovePi+ and GrovePi Zero
  @button_pin 14 # Port A0
  @buzzer_pin 3  # Port D3

  defmodule State do
    @moduledoc false

    defstruct grovepi_pid: nil,
              buzzer_pid: nil
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, grovepi_pid} = GrovePi.start_link
    {:ok, _} = GrovePi.Buttons.start_link(grovepi_pid)
    GrovePi.Buttons.add(@button_pin)
    GrovePi.Buttons.register({:pressed, @button_pin})

    {:ok, buzzer_pid} = GrovePi.Buzzer.start_link(grovepi_pid, @buzzer_pin)

    state = %State{grovepi_pid: grovepi_pid, buzzer_pid: buzzer_pid}
    {:ok, state}
  end

  def handle_info({:pressed, @button_pin}, state) do
    IO.puts("Alert!!!!")

    # Sound the alarm, but only for a second
    GrovePi.Buzzer.buzz(state.buzzer_pid, 1000)

    {:noreply, state}
  end
end

defmodule Alarm do
  @moduledoc false
  use Application

  # Pick ports that work on both the GrovePi+ and GrovePi Zero
  @button_pin 14 # Port A0
  @buzzer_pin 3  # Port D3

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the GrovePi sensors that we want
      worker(GrovePi.Button, [@button_pin]),
      worker(GrovePi.Buzzer, [@buzzer_pin]),

      # Start the main app
      worker(Alarm.Worker, [[@button_pin, @buzzer_pin]]),
    ]

    opts = [strategy: :one_for_one, name: Alarm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule Worker do
    use GenServer

    defstruct [:button, :buzzer]

    def start_link(pins) do
      GenServer.start_link(__MODULE__, pins)
    end

    def init([button, buzzer]) do
      state = %Worker{button: button, buzzer: buzzer}

      GrovePi.Button.subscribe(state.button, :pressed)
      {:ok, state}
    end

    def handle_info({_, :pressed}, state) do
      IO.puts("Alert!!!!")

      # Sound the alarm, but only for a second
      GrovePi.Buzzer.buzz(state.buzzer, 1000)

      {:noreply, state}
    end
  end
end

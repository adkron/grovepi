defmodule LEDFade do
  @moduledoc false
  use GenServer

  defstruct [:potentiometer, :led]

  def start_link(pins) do
    GenServer.start_link(__MODULE__, pins)
  end

  def init([potentiometer, led]) do
    state = %LEDFade{potentiometer: potentiometer, led: led}

    GrovePi.Potentiometer.subscribe(potentiometer, :changed)
    {:ok, state}
  end

  def handle_info({_, :changed, %{value: value}}, state) do
    led_value = convert_to_pwm(value)

    # Write new value to led
    GrovePi.Analog.write(state.led, led_value)

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp convert_to_pwm(value) do
    # Convert adc_level value (0-1023) to pwm value (0-255)
    round(value / 5)
  end
end

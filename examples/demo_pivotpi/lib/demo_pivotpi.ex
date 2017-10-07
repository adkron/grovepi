defmodule DemoPivotPi do
  @moduledoc """
  Sample functions to demonstrate and test GrovePi.RGBLCD module
  """

  alias GrovePi.PivotPi

  @doc """
  Connect PivotPi to the GrovePi I2C port.  Connect servos to
  channels 1-8.  Not required to have a servo in every channel.
  """
  def cycle_servos() do
    PivotPi.start()
    do_cycle_servos()
  end

  defp do_cycle_servos() do
    for num <- 1..8 do
      PivotPi.angle(num, 0)
      PivotPi.led(num, 0)
      Process.sleep(500)
    end

    for num <- 1..8 do
      PivotPi.angle(num, :rand.uniform(180))
      PivotPi.led(num, :rand.uniform(100))
      Process.sleep(500)
    end
    do_cycle_servos()
  end
end

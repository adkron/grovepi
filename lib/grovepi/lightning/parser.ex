defmodule GrovePi.Lightning.Parser do
  defstruct [:gain, :distance, :interrupt]
  def parse(<<next::binary-size(1), rest::binary>>) do
    reading = %__MODULE__{
      gain: :indoor
    }
    parse_byte(rest, next, reading)
  end

  defp parse_byte(<<>>, <<_::bits-size(2), distance::1*6>>, reading) do
    add_distance(reading, distance)
  end

  defp parse_byte(<<next::binary-size(1), rest::binary-size(6)>>, <<_::bits-size(2), gain::1*5, _::bits-size(1)>>, reading) do
    parse_byte(rest, next, add_gain(reading, gain))
  end

  defp parse_byte(<<next::binary-size(1), rest::binary-size(3)>>, <<_::bits-size(4), interrupt::1*4>>, reading) do
    parse_byte(rest, next, add_interrupt(reading, interrupt))
  end

  defp parse_byte(<<next::binary-size(1), rest::binary>>, _, reading) do
    parse_byte(rest, next, reading)
  end

  defp add_distance(reading, 0b000000), do: %{reading | distance: :overhead}
  defp add_distance(reading, 0b111111), do: %{reading | distance: :out_of_range}
  defp add_distance(reading, distance), do: %{reading | distance: distance}

  defp add_gain(reading, 0b10010), do: %{reading | gain: :indoor}
  defp add_gain(reading, 0b01110), do: %{reading | gain: :outdoor}

  defp add_interrupt(reading, 0b0000), do: %{reading | interrupt: :none}
  defp add_interrupt(reading, 0b0001), do: %{reading | interrupt: :noise_level_too_high}
  defp add_interrupt(reading, 0b0100), do: %{reading | interrupt: :disturber_detected}
  defp add_interrupt(reading, 0b1000), do: %{reading | interrupt: :lightning}
end

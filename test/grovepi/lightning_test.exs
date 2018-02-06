defmodule GrovePi.Lightning.Parser do
  defstruct [:gain, :distance, :interrupt]
  def parse(<<next::binary-size(1), rest::binary>>) do
    reading = %__MODULE__{
      gain: :indoor
    }
    parse_byte(rest, next, reading)
  end

  defp parse_byte(<<>>, <<_::bits-size(2), distance::1*6>>, reading) do
    %{reading | distance: parse_distance(distance)}
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

  defp parse_distance(0b000000), do: :overhead
  defp parse_distance(0b111111), do: :out_of_range
  defp parse_distance(distance), do: distance

  defp add_gain(reading, 0b10010), do: %{reading | gain: :indoor}
  defp add_gain(reading, 0b01110), do: %{reading | gain: :outdoor}

  defp add_interrupt(reading, 0b0000), do: %{reading | interrupt: :none}
  defp add_interrupt(reading, 0b0001), do: %{reading | interrupt: :noise_level_too_high}
  defp add_interrupt(reading, 0b0100), do: %{reading | interrupt: :disturber_detected}
  defp add_interrupt(reading, 0b1000), do: %{reading | interrupt: :lightning}
end

defmodule GrovePi.Lightning.Parser.Test do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias GrovePi.Lightning.Parser, as: Subject

  property "parses every type" do
    check all gain <- one_of([constant(0b10010), constant(0b01110)]),
      power_down <- constant(0),
      noise_floor_level <- integer(0b000..0b111),
      watch_dog_threshold <- constant(0b0001),
      clear_statistics <- constant(1),
      minimum_number_of_lightning <- constant(0b00),
      spike_rejection <- integer(0b0000..0b1111),
      lco_fdiv <- constant(0b00),
      mask_disturber <- constant(0b0),
      interrupt <- one_of([constant(0b0000), constant(0b0001), constant(0b0100), constant(0b1000),]),
      energy_lsb <- integer(0b00000000..0b11111111),
      energy_msb <- integer(0b00000000..0b11111111),
      energy_mmsb <- integer(0b00000..0b11111),
      distance <- integer(0b000000..0b111111),
        input = <<
          0::1*2,
          gain::1*5,
          power_down::1*1,
        >> <>
          <<
        0::1*1,
          noise_floor_level::1*3,
          watch_dog_threshold::1*4,
          >> <>
            <<
        1::1*1,
          clear_statistics::1*1,
          minimum_number_of_lightning::1*2,
          spike_rejection::1*4,
          >> <>
            <<
        lco_fdiv::1*2,
          mask_disturber::1*1,
          0::1*1,
          interrupt::1*4,
          >> <>
            <<energy_lsb>> <>
              <<energy_msb>> <>
                <<
        0::1*3,
          energy_mmsb::1*5,
          >> <>
            <<
        0::1*2,
        distance::1*6,
        >>
        do

        output = Subject.parse(input)
          case gain do
            0b10010 ->
              assert output.gain == :indoor
            0b01110 ->
              assert output.gain == :outdoor
          end

          case distance do
            0b111111 ->
              assert output.distance == :out_of_range
            0b000000 ->
              assert output.distance == :overhead
            _ ->
              assert output.distance == distance
          end

          case interrupt do
            0b0001 -> assert output.interrupt == :noise_level_too_high
            0b0100 -> assert output.interrupt == :disturber_detected
            0b1000 -> assert output.interrupt == :lightning
            0b0000 -> assert output.interrupt == :none
          end

      end

  end
end

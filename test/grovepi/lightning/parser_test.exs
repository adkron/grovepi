defmodule GrovePi.Lightning.Parser.Test do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias GrovePi.Lightning.Parser, as: Subject

  def interrupt do
    one_of(
      [
        tuple({constant(:none), constant(0b0000)}),
        tuple({constant(:noise_level_too_high), constant(0b0001)}),
        tuple({constant(:disturber_detected), constant(0b0100)}),
        tuple({constant(:lightning), constant(0b1000)}),
      ]
    )
  end

  def gain do
    one_of(
      [
        tuple({constant(:indoor), constant(0b10010)}),
        tuple({constant(:outdoor), constant(0b01110)}),
      ]
    )
  end

  def distance(known_distance) do
    one_of(
      [
        tuple({constant(:out_of_range), constant(0b111111)}),
        tuple({constant(known_distance), constant(known_distance)}),
        tuple({constant(:overhead), constant(0b000000)}),
      ]
    )
  end

  property "parses every type" do
    check all {gain_result, gain_value} <- gain(),
      power_down <- constant(0),
      noise_floor_level <- integer(0b000..0b111),
      watch_dog_threshold <- constant(0b0001),
      clear_statistics <- constant(1),
      minimum_number_of_lightning <- constant(0b00),
      spike_rejection <- integer(0b0000..0b1111),
      lco_fdiv <- constant(0b00),
      mask_disturber <- constant(0b0),
      {interrupt_result, interrupt_value} <- interrupt(),
      energy_lsb <- integer(0b00000000..0b11111111),
      energy_msb <- integer(0b00000000..0b11111111),
      energy_mmsb <- integer(0b00000..0b11111),
      known_distance <- integer(0b000001..0b111110),
      {distance_result, distance_value} <- distance(known_distance),
      input = <<
    0::1*2,
      gain_value::1*5,
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
      interrupt_value::1*4,
      >> <>
        <<energy_lsb>> <>
          <<energy_msb>> <>
            <<
      0::1*3,
      energy_mmsb::1*5,
      >> <>
        <<
      0::1*2,
      distance_value::1*6,
      >>
      do

        output = Subject.parse(input)

        assert output.distance == distance_result
        assert output.gain == gain_result
        assert output.interrupt == interrupt_result
      end
  end
end

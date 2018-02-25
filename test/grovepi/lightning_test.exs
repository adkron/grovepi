defmodule GrovePi.Lightning.Test do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias GrovePi.Lightning, as: Subject
  import Mox

  setup do
    {:ok, _pid} = start_supervised Subject
    allow(GrovePi.MockBoard, self(), GenServer.whereis(GrovePi.Lightning.Server))
    :ok
  end

  property "reading" do
    Subject.subscribe(:lightning)
    Subject.subscribe(:disturber_detected)
    Subject.subscribe(:noise_level_too_high)

    sensor_output = gen all gain <- one_of([constant(:indoor), constant(:outdoor)]),
      distance <- one_of([constant(:overhead), constant(:out_of_range), integer(1..62)]),
      interrupt <- one_of([
        constant(:none),
        constant(:noise_level_too_high),
        constant(:disturber_detected),
        constant(:lightning),
      ])
    do
      %{
        gain: gain,
        distance: distance,
        interrupt: interrupt,
      }
    end

    check all output <- sensor_output do
      stub(GrovePi.MockBoard, :read, fn(%{address: 0x04}, 8)->
        output
      end)

      Subject.read()

      interrupt = output.interrupt
      distance = output.distance

      assert output.gain == Subject.gain()
      if interrupt != :none, do: assert_receive {^interrupt, ^distance}
      refute_receive {:none, _}
    end
  end

  property "setting" do
    check all gain <- one_of([constant(:indoor), constant(:outdoor)]) do
      expect(GrovePi.MockBoard, :write, 1, fn(%{address: 0x04}, %{setting: :gain, value: ^gain})->
        :ok
      end)

      Subject.gain(gain)

      assert gain == Subject.gain()
      verify!()
    end
  end
end

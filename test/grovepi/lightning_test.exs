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

  def gain do
    one_of([constant(:indoor), constant(:outdoor)])
  end

  def sensor_output do
    gen all gain <- gain(),
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
  end

  property "reading" do
    Subject.subscribe(:lightning)
    Subject.subscribe(:disturber_detected)
    Subject.subscribe(:noise_level_too_high)

    check all output <- sensor_output() do
      stub(GrovePi.MockBoard, :read, fn(%{address: 0x03}, 8)->
        output
      end)

      Subject.read!

      interrupt = output.interrupt
      distance = output.distance

      assert output.gain == Subject.gain()
      if interrupt != :none, do: assert_receive {^interrupt, ^distance}
      refute_receive {:none, _}
    end
  end

  property "setting" do
    check all gain <- gain(), max_rns: 1 do
      expect(GrovePi.MockBoard, :write, 1, fn(%{address: 0x03}, %{setting: :gain, value: ^gain})->
        :ok
      end)

      Subject.gain(gain)

      assert gain == Subject.gain()
      verify!()
    end
  end

  test "reading gain" do
    #output = Enum.at(sensor_output(), 1)
    #stub(GrovePi.MockBoard, :read, fn(%{address: 0x03}, 8)->
      #output
    #end)

    #send GenServer.whereis(Subject.Server), :read

    assert Subject.gain() == :indoor
  end

  test "changing gain setting" do
    expected_gain = :outdoor
    expect(GrovePi.MockBoard, :write, 1,
           fn(%{address: 0x03}, %{setting: :gain, value: ^expected_gain})->
             :ok
           end)

    Subject.gain(expected_gain)

    assert Subject.gain == expected_gain
  end

  test "reading results from the sensor" do
    output = Enum.at(sensor_output(), 1)
    stub(GrovePi.MockBoard, :read, fn(%{address: 0x03}, 8)->
      output
    end)

    send GenServer.whereis(Subject.Server), :read

    interrupt = output.interrupt
    distance = output.distance

    assert output.gain == Subject.gain()
    assert {interrupt, distance} == Subject.last_strike()
  end
end

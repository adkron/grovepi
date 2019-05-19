defmodule HomeWeatherDisplayTest do
  use ExUnit.Case
  doctest HomeWeatherDisplay

  test "greets the world" do
    assert HomeWeatherDisplay.hello() == :world
  end
end

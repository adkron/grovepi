defmodule ComponentTestCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      @pin 5
      @moduletag report: [:prefix, :board]
    end
  end

  setup tags do
    prefix = String.to_atom(Time.to_string(Time.utc_now))
    board = GrovePi.Board.i2c_name(prefix)

    {:ok, _} = GrovePi.Supervisor.start_link(0x40, prefix)

    GrovePi.I2C.reset(board)

    tags = Map.put(tags, :prefix, prefix)
    tags = Map.put(tags, :board, board)
    {:ok, tags}
  end
end


defmodule GrovePi.Lightning.Server do
  use GenServer
  alias GrovePi.Lightning.SettingUpdate
  @poll_interval 100

  defstruct [
    address: 0x04,
    gain: :indoor,
    distance: :not_read,
    interrupt: :none,
    poll_timer: nil,
  ]

  @type t :: %__MODULE__{
    address: 0x04,
    gain: :indoor | :outdoor,
    distance: :overhead | 1..62 | :out_of_range | :not_read,
    interrupt: :none | :noise_level_too_high | :disturber_detected | :lightning,
    poll_timer: term,
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    {:ok, %__MODULE__{address: 0x04} |> poll()}
  end

  @board Application.get_env(:grovepi, :board, GrovePi.Board)

  def handle_call(:read_cached, _from, device), do: {:reply, device, device}

  def handle_call(:read, _from, device) do
    new_state = read(device)
    {:reply, new_state, new_state}
  end

  def handle_info(:read, device) do
    {:noreply, read(device)}
  end

  def handle_cast(:read, device) do
    {:noreply, read(device)}
  end

  def handle_cast({:set, setting, value}, device) do
    command = %SettingUpdate{setting: setting, value: value}
    @board.write(device, command)
    {:noreply, %{device | gain: value}}
  end

  defp poll(device) do
    %{device | poll_timer: Process.send_after(self(), :read, @poll_interval)}
  end

  defp read(device) do
    output = @board.read(device, 8)
    device = Map.merge(device, output) |> poll()
    GrovePi.Lightning.notify(device)
    device
  end

  defimpl GrovePi.Parsable do
    def parse(device, binary) do
      Map.merge(device, GrovePi.Lightning.Parser.parse(binary))
    end
  end
end

defmodule GrovePi.Lightning.SettingUpdate do
  defstruct [:setting, :value]

  defimpl GrovePi.Writable do
    def to_binary(%{setting: :gain, value: :indoor}) do
      <<0x00,
        0::1*2,
        0b10010::1*5,
        0::1*1,
        >>
    end

    def to_binary(%{setting: :gain, value: :outdoor}) do
      <<0x00,
        0::1*2,
        0b01110::1*5,
        0::1*1,
        >>
    end
  end
end

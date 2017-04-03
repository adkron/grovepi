use Mix.Config

i2c_implementation =
  case Mix.env() do
    :prod -> ElixirALE.I2C
    _ -> GrovePi.I2C
  end

config :grovepi, i2c: i2c_implementation

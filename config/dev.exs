use Mix.Config

config :grovepi, :i2c, GrovePi.I2C

config :mix_test_watch,
  tasks: [
    "test",
    #"credo --strict",
  ]

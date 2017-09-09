# Demo RGBLCD

This project demonstrates the functions available in the GrovePi.RGBLCD module.

On the GrovePi+ or GrovePi Zero, connect a RGBLCD Display to the I2C-1 port.

If you're on Raspbian, try this out by running:

```shell
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod iex -S mix
```

```elixir
iex(1)> DemoRGBLCD.autoscroll()
iex(2)> DemoRGBLCD.blink()
iex(3)> DemoRGBLCD.cursor()
iex(4)> DemoRGBLCD.colors()
iex(5)> DemoRGBLCD.display()
iex(6)> DemoRGBLCD.text_direction()
iex(7)> DemoRGBLCD.set_cursor()
```

Most functions are on a loop and will require exit from IEx to run a different
function.

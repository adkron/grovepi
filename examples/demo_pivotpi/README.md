# Demo PivotPi

This project demonstrates the functions available in the GrovePi.PivotPi module.

On the GrovePi+ or GrovePi Zero, connect a PivotPi to the I2C-1 port. Connect
servos to channels 1-8.  You do not need a servo in each channel.

The GrovePi will cycle through servos 1-8 changing the servo angle and 
LED brightness to 0.  Then it will cycle through the servos again changing the 
servo angle to a random number between 0-180 and the LED to a random number
between 0-100.

If you're on Raspbian, try this out by running:

```shell
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod iex -S mix
```

```elixir
iex(1)> DemoPivotPi.cycle_servos()
```

Function is on a loop and will require exit from IEx to stop.

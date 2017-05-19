# Home Weather Display

This example reads a digital humidity and temperature (DHT) sensor and updates a 
RGB LCD display.  The project is configured for the DHT11 sensor which comes with 
the GrovePi+ Starter Kit (the blue one).

On the GrovePi+ or GrovePi Zero, connect a DHT11 to port 7 and a RGB LCD display 
to the IC2-1 port.

This project was created as a Nerves app. To start your Nerves app:
  * `export NERVES_TARGET=my_target` or prefix every command with `NERVES_TARGET=my_target`, Example: `NERVES_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

# Changelog

## v0.4.1

* Move ownership of repository to adkron.

## v0.4.0

* Replaced DHT with DHT11. Now there's only one DHT module and it uses
  the poller.

## v0.3.2

* Add more examples including an LED fader and weather monitor
* Bump ElixirALE to 1.0

## v0.3.1

* Moves ElixirALE to 0.6.2
* Add credo and mix test watch for development

## v0.3.0

* Add support for sound trigger with a [hysteresis][hysteresis] triggering
  mechanism
* Change events to include the trigger state
* Create Poller behaviour to facilitate polling for changes, ex. Button and
  Sound
* Create Trigger behaviour for creating custom triggers to trigger polling
  events
* Allow Triggers to receive a set of options through the poller starting

[hysteresis]: https://en.wikipedia.org/wiki/Hysteresis

## v0.1.0

Initial release

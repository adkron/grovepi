# GrovePi

[![Build Status](https://travis-ci.org/fhunleth/grovepi.svg?branch=master)](https://travis-ci.org/fhunleth/grovepi)
[![Ebert](https://ebertapp.io/github/fhunleth/grovepi.svg)](https://ebertapp.io/github/fhunleth/grovepi)

Use the [GrovePi+][dexter] and sensors in Elixir on a Raspberry Pi. If you have
a Beaglebone Green or other port that has direct access to sensors (rather than
going through a GrovePi+), take a look at [nerves_grove][nerves_grove].

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `grovepi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:grovepi, "~> 0.3.0"}]
end
```

The `grovepi` library uses [elixir_ale][ale] for I2C communication to the
GrovePi+. This only works on Raspberry Pi computers. If you're working on
another platform, a stub is available for debugging and testing. When building
`grovepi` standalone, be aware that `elixir_ale` is only used for `MIX_ENV=prod`
builds. To use the stub in your own programs, add the following to your
configuration:

```elixir
  config :grovepi, :i2c, GrovePi.I2C
```

## API Documentation

See the generated documentation at [hexdocs.pm/grovepi][docs].

# Contributions

We welcome contributions to tackle issues in GrovePi.

## Setup

First fork the repository and fetch your own copy

```bash
mix deps.get
mix test
```

## Submitting a Pull Request

1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Add tests for your unimplemented feature or bug fix.
4. Run `mix test`. If your tests pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `mix test`. If your tests fail, return to step 5.
7. Commit, and push your changes.
8. [Submit a pull request.][pr]

## Running Tests

All tests can be run with `mix test` or a single test file can be run
with `mix test path/to/file_test.exs`.

If you would like tests to run in the background as you change files you
can run `mix test.watch`.

[dexter]: https://www.dexterindustries.com/grovepi/
[nerves_grove]: https://github.com/bendiken/nerves_grove/
[ale]: https://hex.pm/packages/elixir_ale
[docs]: https://hexdocs.pm/grovepi
[fork]: https://help.github.com/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/creating-a-pull-request/

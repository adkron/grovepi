# GrovePi

Use the [GrovePi](https://www.dexterindustries.com/grovepi/) and sensors in Elixir
on a Raspberry Pi. If you have a Beaglebone Green or other port that has direct
access to sensors (rather than going through a GrovePi), take a look at
[nerves_grove](https://github.com/bendiken/nerves_grove). This library will
likely go through many changes in the coming months and possibly get merged into
`nerves_grove` should there be enough overlap.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `grovepi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:grovepi, "~> 0.1.0"}]
end
```

But for now, add this:

```elixir
def deps do
  [{:grovepi, github: "fhunleth/grovepi", branch: "master"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/grovepi](https://hexdocs.pm/grovepi).


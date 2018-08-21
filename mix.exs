defmodule GrovePi.Mixfile do
  use Mix.Project

  @name "GrovePi"
  @version "0.6.1"
  @github "https://github.com/adkron/grovepi"
  @homepage @github

  def project do
    [
      app: :grovepi,
      version: @version,
      elixir: "~> 1.7",
      name: @name,
      description: description(),
      package: package(),
      source_url: @github,
      homepage_url: @homepage,
      docs: [extras: ["README.md"]],
      aliases: aliases(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {GrovePi, []}]
  end

  defp description do
    """
    Use Dexter Industries' GrovePi+ and GrovePiZero boards and many Grove sensors.
    """
  end

  defp deps do
    [
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:elixir_ale, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:credo, "~> 0.7", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["Amos King", "Frank Hunleth"],
      licenses: ["Apache License"],
      links: %{"GitHub" => @github}
    ]
  end

  # Copy the images referenced by docs, since ex_doc doesn't do this.
  defp copy_images(_) do
    File.cp_r("assets", "doc/assets")
  end

  defp aliases do
    [
      docs: ["docs", &copy_images/1]
    ]
  end
end

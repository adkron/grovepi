defmodule GrovePi.Mixfile do
  use Mix.Project

  @name      "GrovePi"
  @version   "0.1.0"
  @github    "https://github.com/fhunleth/grovepi"
  @homepage  @github

  def project do
    [app: :grovepi,
     version: @version,
     elixir: "~> 1.4",
     name: @name,
     description: description(),
     package: package(),
     source_url: @github,
     homepage_url: @homepage,
     docs: [extras: ["README.md"]],
     aliases: ["docs": ["docs", &copy_images/1]],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application, do: []

  defp description do
    """
    Use Dexter Industries' GrovePi+ and GrovePiZero boards and many Grove sensors.
    """
  end

  defp deps do
    [{:elixir_ale,  "~> 0.5.7", only: [:prod]},
     {:dialyxir,    ">= 0.0.0", only: [:dev, :test]},
     {:ex_doc,      ">= 0.0.0", only: :dev}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md"],
     maintainers: ["Frank Hunleth"],
     licenses: ["Apache License"],
     links: %{"GitHub" => @github}]
  end

  # Copy the images referenced by docs, since ex_doc doesn't do this.
  defp copy_images(_) do
    File.cp_r "assets", "doc/assets"
  end
end

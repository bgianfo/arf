defmodule Arf.Mixfile do
  use Mix.Project

  def project do
    [
      app: :arf,
      version: "0.0.1",
      elixir: "~> 1.0",
      desription: description,
      package: package,
      deps: deps,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      { :statistics, "~> 0.2.0" },
      { :excoveralls, "~> 0.3", only: [:dev, :test] }
    ]
  end

  defp description do
    "Implementation of an Adaptive Range Filter"
  end

  defp package do
    [
      files: ~w(lib test mix.exs README.md LICENSE.md),
      contributors: ["Brian Gianforcaro"],
      licenses: ["BSD"],
      links: %{
                "GitHub" => "https://github.com/bgianfo/arf",
                "Theoretical Description Of The Data Structure" => "http://www.vldb.org/pvldb/vol6/p1714-kossmann.pdf"
              }
    ]
  end

end

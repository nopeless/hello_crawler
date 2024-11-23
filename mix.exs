defmodule HelloCrawler.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hello_crawler,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HelloCrawler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.2.1"},
      {:floki, "~> 0.36.0"}
    ]
  end
end

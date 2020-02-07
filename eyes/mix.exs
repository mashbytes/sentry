defmodule Eyes.MixProject do
  use Mix.Project

  def project do
    [
      app: :eyes,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Eyes.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:picam, "~> 0.4.0"},
      # {:cowboy, "~> 2.7.0"},
      # {:plug, "~> 1.8.3"},
      {:plug_cowboy, "~> 2.1"}
    ]
  end
end

defmodule Exp.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :exp,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: "Execute and inline code at compile time.",
      source_url: "https://github.com/orsinium-labs/exp",
      homepage_url: "https://github.com/orsinium-labs/exp",
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/orsinium-labs/exp"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 1.6.0", only: :dev, runtime: false}
    ]
  end
end

defmodule Pickle.Mixfile do
  use Mix.Project

  @version "0.5.0"
  def project do
    [
      app: :pickle,
      version: @version,
      elixir: "~> 1.3",
      source_url: "git@github.com:Mathison-Inc/pickle.git",
      homepage_url: "https://github.com/Mathison-Inc/pickle",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Story BDD tool for executing elixir in ExUnit",
      docs: [
        main: Pickle,
        readme: "README.md"
      ],
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:gherkin, "~> 1.6.0"},
      {:ex_doc, "~> 0.25.0", only: :dev},
      {:earmark, "~> 1.4.15", only: :dev},
      {:excoveralls, "~> 0.14.2", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Potiguar Catalan"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/Mathison-Inc/pickle"}
    ]
  end
end

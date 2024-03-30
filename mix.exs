defmodule ExtFit.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ext_fit,
      version: @version,
      elixir: "~> 1.15",
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      package: package(),
      name: "ExtFit",
      source_url: "https://github.com/arathunku/ext_fit",
      homepage_url: "https://github.com/arathunku/ext_fit",
      docs: &docs/0,
      description: """
        Garmin FIT file decoder
      """,
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        check: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cldr_utils, "~> 2.24"},
      {:excoveralls, "~> 0.18.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:csv, "~> 3.2", only: [:test]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "clean",
        "deps.unlock --check-unused",
        "compile --warnings-as-errors",
        "format --check-formatted",
        "deps.unlock --check-unused",
        "test --warnings-as-errors",
        "dialyzer --format short",
        "credo"
      ]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/arathunku/ext_fit",
      extras: extras(),
      groups_for_extras: [
        Examples: Path.wildcard("examples/*")
      ],
      formatters: ["html"],
      main: "readme",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  def extras do
    [
      "README.md": [title: "Overview"],
      "CHANGELOG.md": [title: "Changelog"],
      "CONTRIBUTING.md": [title: "Contributing"],
      "LICENSE.md": [title: "License"],
      "TODO.md": [title: "TODO"]
    ] ++ Path.wildcard("examples/*.livemd")
  end

  defp package do
    [
      maintainers: ["@arathunku"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/ext_fit/changelog.html",
        GitHub: "https://github.com/arathunku/ext_fit"
      },
      files: ~w(lib CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end
end

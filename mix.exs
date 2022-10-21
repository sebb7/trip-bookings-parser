defmodule TripBookingsParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :trip_bookings_parser,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:nimble_parsec, "~> 1.2.3"},
      {:ecto, "~> 3.8"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end

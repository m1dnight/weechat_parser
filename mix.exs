defmodule WeechatParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :weechat_parser,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 1.0"},
      {:timex, "~> 3.0"}
    ]
  end
end

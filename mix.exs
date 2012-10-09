defmodule Exn.Mixfile do
  use Mix.Project

  def project do
    [ app: :exn,
      version: "0.0.1",
      deps: deps,
      env: [test: [deps: deps(:test)]]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp deps do
    []
  end

  defp deps(:test) do
    [{:properex, github: "yrashk/properex"}]
  end
end

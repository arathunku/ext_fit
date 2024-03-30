defmodule ExtFit do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- @moduledoc -->")
             |> Enum.fetch!(1)
  @external_resource "README.md"
end

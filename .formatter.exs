# Used by "mix format"
[
  plugins: [Styler],
  inputs:
    ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
    |> Enum.flat_map(&Path.wildcard(&1, match_dot: true))
    |> Enum.reject(&(&1 =~ "lib/ext_fit/profile/")),
  # makes it easier to read longer binary matching definitions
  line_length: 118
]

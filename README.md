<!-- @moduledoc -->

# ExtFit

`.fit` file decoder. See `ExtFit.Decode` module for more details and usage.

It's still in alpha-release and there's a slim chance that the format of returned
structs will change but if possible, will be avoided.

Currently used FIT profile can be seen in `ExtFit.Profile.Types` file.

## TODOs

Decoder is usable but there's still a lot to do!

Any help would be highly appreciated!

- **!!!!! Creating and writing .fit files, this library doesn't have encoder**
- Calculate CRC values
- Streaming out processed records
- Option to decode only specific messages. Example: [{:hr}]
- Option to decode only specific fields: Example: {nil, :avg_speed"} or {:lap, :avg_speed}
- Option to skip CRC calculation
- Option to skip unknown records or fields
- Performance - unroll some of the decoding, take a look at how JSON decoders are optimized
- Helper to convert output to dataframes for usage in smart cells
- TBD: Replace all floats with Decimals? Probably not, couldn't be done via Processor
- TBD: Replace Field.name() and Record.name() with names directly in structs?
- Wrap in [burrito](https://github.com/burrito-elixir/burrito) and provide CLI

<!-- @moduledoc -->

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ext_fit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ext_fit, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/ext_fit>.

## Contributing

Before contributing to this project, please read the CONTRIBUTING.md.

## License

Copyright © 2024 Michal Forys

This project is licensed under the MIT license.

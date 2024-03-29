# TODO

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
- TBD: Replace all floats with Decimals? Probably not, could be done via Processor when needed
- Wrap in [burrito](https://github.com/burrito-elixir/burrito) and provide CLI
- LiveBook examples for other sports

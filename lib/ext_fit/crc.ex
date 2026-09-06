defmodule ExtFit.CRC do
  @moduledoc """
  Calculates the CRC-16 used by FIT file headers and data streams.

  The implementation follows the FIT protocol's nibble-at-a-time algorithm.
  """

  import Bitwise

  @crc_table {
    0x0000,
    0xCC01,
    0xD801,
    0x1400,
    0xF001,
    0x3C00,
    0x2800,
    0xE401,
    0xA001,
    0x6C00,
    0x7800,
    0xB401,
    0x5000,
    0x9C01,
    0x8801,
    0x4400
  }

  @spec calculate(binary(), non_neg_integer()) :: non_neg_integer()
  def calculate(binary, initial \\ 0) when is_binary(binary) do
    for <<byte <- binary>>, reduce: initial do
      crc -> update(crc, byte)
    end
  end

  @spec update(non_neg_integer(), byte()) :: non_neg_integer()
  def update(crc, byte) do
    crc = bxor(bxor(crc >>> 4, elem(@crc_table, crc &&& 0xF)), elem(@crc_table, byte &&& 0xF))

    bxor(
      bxor(crc >>> 4, elem(@crc_table, crc &&& 0xF)),
      elem(@crc_table, byte >>> 4 &&& 0xF)
    )
  end
end

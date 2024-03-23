defmodule ExtFit.Chunk do
  @moduledoc """
  Chunk data struct with index for each record, its offset in the file and size.
  """
  defstruct index: 0, offset: 0, size: 0

  @doc false
  def mark(%__MODULE__{offset: offset, index: index} = chunk, byte_size) when is_integer(byte_size) do
    {%{chunk | offset: offset, size: byte_size}, %{chunk | offset: offset + byte_size, index: index + 1}}
  end

  @type t() :: %__MODULE__{
          index: non_neg_integer(),
          offset: non_neg_integer(),
          size: non_neg_integer()
        }
end

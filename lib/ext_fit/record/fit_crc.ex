defmodule ExtFit.Record.FitCrc do
  @derive {Inspect, except: ~w(__chunk__)a}
  defstruct crc: 0, matched: nil, __chunk__: nil

  @type t() :: %__MODULE__{
          crc: non_neg_integer(),
          matched: nil | boolean(),
          __chunk__: ExtFit.Chunk.t()
        }
end

defmodule ExtFit.Record.FitHeader do
  @moduledoc false
  @derive {Inspect, except: ~w(__chunk__)a}
  defstruct header_size: 0,
            type_frame: nil,
            proto_ver: 0,
            profile_ver: 0,
            body_size: 0,
            crc: nil,
            __chunk__: nil

  @type t() :: %__MODULE__{
          header_size: non_neg_integer(),
          type_frame: bitstring(),
          proto_ver: non_neg_integer(),
          profile_ver: non_neg_integer(),
          body_size: non_neg_integer(),
          crc: ExtFit.Record.FitCrc.t(),
          __chunk__: ExtFit.Chunk.t()
        }
end

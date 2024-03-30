defmodule ExtFit.Record.FitData do
  @moduledoc false
  @header ~w(is_developer_data local_mesg_num time_offset)a
  @payload ~w(def_mesg fields)a

  @derive {Inspect, except: ~w(__chunk__)a}
  defstruct @header ++ @payload ++ ~w(__chunk__)a

  @type t() :: %__MODULE__{
          def_mesg: nil | struct(),
          fields: list(ExtFit.Types.FieldData.t()),
          is_developer_data: boolean(),
          local_mesg_num: non_neg_integer(),
          time_offset: non_neg_integer(),
          __chunk__: ExtFit.Chunk.t()
        }
end

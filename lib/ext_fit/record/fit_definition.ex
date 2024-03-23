defmodule ExtFit.Record.FitDefinition do
  @header ~w(is_developer_data local_mesg_num time_offset)a
  @payload ~w(mesg_type global_mesg_num endian field_defs dev_field_defs)a

  @derive {Inspect, except: ~w(__chunk__)a}
  defstruct @header ++ @payload ++ ~w(__chunk__)a

  @type t() :: %__MODULE__{
          mesg_type: nil | map(),
          global_mesg_num: nil | non_neg_integer(),
          field_defs: list(ExtFit.Types.Field.t()),
          dev_field_defs: list(ExtFit.Types.DevField.t()),
          endian: :little | :big,
          is_developer_data: boolean(),
          local_mesg_num: non_neg_integer(),
          time_offset: non_neg_integer(),
          __chunk__: ExtFit.Chunk.t()
        }
end

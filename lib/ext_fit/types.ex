defmodule ExtFit.Types.BaseType do
  @moduledoc false
  defstruct name: nil, id: nil, size: nil, invalid: nil

  @type t() :: %__MODULE__{
          name: atom(),
          id: non_neg_integer(),
          size: non_neg_integer(),
          invalid: nil | non_neg_integer()
        }

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{name: name, id: id}, opts) do
      id = to_doc(id, Map.put(opts, :base, :hex))

      doc = concat(["#BaseType<", id, ",", " ", ":" <> Atom.to_string(name), ">"])
      IO.iodata_to_binary(Inspect.Algebra.format(doc, :infinity))
    end
  end
end

defmodule ExtFit.Types.FieldType do
  @moduledoc false
  @derive {Inspect, except: ~w(values)a}
  defstruct name: nil, base_type: nil, values: %{}

  @type t() :: %__MODULE__{
          name: atom(),
          base_type: ExtFit.Types.BaseType.t(),
          # values: %{non_neg_integer() => ExtFit.Types.FieldTypeValue.t()}
          values: %{non_neg_integer() => ExtFit.Types.FieldTypeValue.t()}
        }
end

defmodule ExtFit.Types.FieldTypeValue do
  @moduledoc false
  defstruct num: nil, name: nil

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer()
        }
end

defmodule ExtFit.Types.Field do
  @moduledoc false
  @derive {Inspect, optional: ~w(scale offset units components array subfields)a}
  defstruct name: nil,
            type: nil,
            num: nil,
            scale: nil,
            offset: nil,
            units: nil,
            components: [],
            array: false,
            subfields: []

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          type: ExtFit.Types.FieldType.t() | ExtFit.Types.BaseType.t(),
          scale: nil | non_neg_integer(),
          offset: nil | integer(),
          units: nil | String.t(),
          components: list(ExtFit.Types.ComponentField.t()),
          array: boolean(),
          subfields: list(ExtFit.Types.Subfield.t())
        }
end

defmodule ExtFit.Types.Subfield do
  @moduledoc false
  @derive {Inspect, optional: ~w(scale offset units components ref_fields)a}
  defstruct name: nil,
            type: nil,
            num: nil,
            scale: nil,
            offset: nil,
            units: nil,
            components: [],
            ref_fields: []

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          # type: ExtFit.Profile.Types.t() | ExtFit.Types.BaseType.t(),
          scale: nil | non_neg_integer(),
          offset: nil | integer(),
          units: nil | String.t(),
          components: list(ExtFit.Types.ComponentField.t()),
          ref_fields: list(ExtFit.Types.ReferenceField.t())
        }
end

defmodule ExtFit.Types.DevField do
  @moduledoc false
  defstruct dev_data_index: nil, name: nil, type: nil, num: nil, units: nil, native_field_num: nil

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          native_field_num: non_neg_integer(),
          dev_data_index: non_neg_integer(),
          units: nil | String.t(),
          type: ExtFit.Types.BaseType.t()
        }
end

defmodule ExtFit.Types.ReferenceField do
  @moduledoc false
  defstruct name: nil, value: nil, raw_value: nil, num: nil

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          value: any(),
          raw_value: non_neg_integer()
        }
end

defmodule ExtFit.Types.ComponentField do
  @moduledoc false
  @derive {Inspect, optional: ~w(scale offset units is_accumulated)a}
  defstruct name: nil,
            num: nil,
            scale: nil,
            offset: nil,
            units: nil,
            is_accumulated: false,
            bits: nil,
            bit_offset: nil

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          scale: nil | non_neg_integer(),
          offset: nil | integer(),
          units: nil | String.t(),
          is_accumulated: boolean(),
          bits: non_neg_integer(),
          bit_offset: non_neg_integer()
        }
end

defmodule ExtFit.Types.MessageType do
  @moduledoc false
  defstruct name: nil, num: nil, fields: []

  @type t() :: %__MODULE__{
          name: atom(),
          num: non_neg_integer(),
          fields: list(ExtFit.Types.Field.t())
        }
end

defmodule ExtFit.Types.FieldDefinition do
  @moduledoc false
  defstruct field: nil, num: nil, base_type: nil, size: nil

  @type t() :: %__MODULE__{
          num: non_neg_integer(),
          field: ExtFit.Types.Field.t(),
          size: non_neg_integer()
        }
end

defmodule ExtFit.Types.DevFieldDefinition do
  @moduledoc false
  defstruct field: nil, dev_data_index: nil, num: nil, size: nil, base_type: nil

  @type t() :: %__MODULE__{
          num: non_neg_integer(),
          size: non_neg_integer(),
          field: ExtFit.Types.Field.t(),
          base_type: ExtFit.Types.BaseType.t(),
          dev_data_index: non_neg_integer()
        }
end

defmodule ExtFit.Types.FieldData do
  @moduledoc false
  alias ExtFit.Field

  defstruct field_def: nil,
            field: nil,
            parent_field: nil,
            value: nil,
            raw_value: nil,
            units: nil,
            value_label: nil

  @type t() :: %__MODULE__{
          field_def: nil | ExtFit.Types.FieldDefinition.t(),
          field: nil | ExtFit.Types.Field.t(),
          parent_field: nil | ExtFit.Types.Field.t() | ExtFit.Types.Subfield.t(),
          value: any(),
          raw_value: nil | non_neg_integer(),
          units: nil | String.t(),
          value_label: nil | String.t()
        }

  @doc """
  Used for inspecting and debugging records. Don't depend on output from it.
  """
  def debug(%__MODULE__{} = fd) do
    details =
      [fd.value_label, inspect(fd.value || fd.raw_value), fd.units]
      |> Enum.filter(&(&1 && &1 != ""))
      |> Enum.join(", ")

    "#{Field.name(fd)}(#{details})"
  end
end

defmodule ExtFit.Types do
  @moduledoc false
  alias ExtFit.Profile
  alias ExtFit.Types.BaseType

  @base_type_byte %BaseType{
    name: :byte,
    id: 0x0D,
    size: 1,
    invalid: :binary.decode_unsigned(<<0xFF>>, :little)
  }

  @base_types %{
    0x00 => %BaseType{name: :enum, id: 0x00, size: 1, invalid: :binary.decode_unsigned(<<0xFF>>, :big)},
    0x01 => %BaseType{name: :sint8, id: 0x01, size: 1, invalid: :binary.decode_unsigned(<<0x7F>>, :big)},
    0x02 => %BaseType{name: :uint8, id: 0x02, size: 1, invalid: :binary.decode_unsigned(<<0xFF>>, :big)},
    0x83 => %BaseType{
      name: :sint16,
      id: 0x83,
      size: 2,
      invalid: :binary.decode_unsigned(<<0x7F, 0xFF>>, :big)
    },
    0x84 => %BaseType{
      name: :uint16,
      id: 0x84,
      size: 2,
      invalid: :binary.decode_unsigned(<<0xFF, 0xFF>>, :big)
    },
    0x85 => %BaseType{
      name: :sint32,
      id: 0x85,
      size: 4,
      invalid: :binary.decode_unsigned(<<0x7F, 0xFF, 0xFF, 0xFF>>, :big)
    },
    0x86 => %BaseType{
      name: :uint32,
      id: 0x86,
      size: 4,
      invalid: :binary.decode_unsigned(<<0xFF, 0xFF, 0xFF, 0xFF>>, :big)
    },
    0x07 => %BaseType{
      name: :string,
      id: 0x07,
      size: 1,
      invalid: :binary.decode_unsigned(<<0>>, :big)
    },
    0x88 => %BaseType{
      name: :float32,
      id: 0x88,
      size: 4,
      invalid: :binary.decode_unsigned(<<0xFF, 0xFF, 0xFF, 0xFF>>, :big)
    },
    0x89 => %BaseType{
      name: :float64,
      id: 0x89,
      size: 8,
      invalid: :binary.decode_unsigned(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>, :big)
    },
    0x0A => %BaseType{name: :uint8z, id: 0x0A, size: 1, invalid: :binary.decode_unsigned(<<0x00>>, :big)},
    0x8B => %BaseType{name: :uint16z, id: 0x8B, size: 2, invalid: :binary.decode_unsigned(<<0x00, 0x00>>, :big)},
    0x8C => %BaseType{
      name: :uint32z,
      id: 0x8C,
      size: 4,
      invalid: :binary.decode_unsigned(<<0x00, 0x00, 0x00, 0x00>>, :big)
    },
    0x8E => %BaseType{
      name: :sint64,
      id: 0x8E,
      size: 8,
      invalid: :binary.decode_unsigned(<<0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>, :big)
    },
    0x0D => @base_type_byte,
    0x8F => %BaseType{
      name: :uint64,
      id: 0x8F,
      size: 8,
      invalid: :binary.decode_unsigned(<<0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>, :big)
    },
    0x90 => %BaseType{
      name: :uint64z,
      id: 0x90,
      size: 8,
      invalid: :binary.decode_unsigned(<<0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>, :big)
    }
  }

  @base_type_by_name Map.new(@base_types, fn {_, type} -> {type.name, type} end)

  # Orders matters here!!!
  @base_type_num [
    0x00,
    0x01,
    0x02,
    0x83,
    0x84,
    0x85,
    0x86,
    0x07,
    0x88,
    0x89,
    0x0A,
    0x8B,
    0x8C,
    0x0D,
    0x8E,
    0x8F,
    0x90
  ]

  def base_type_byte, do: @base_type_byte
  def base_type_by_name(name) when is_atom(name), do: Map.get(@base_type_by_name, name)
  def base_type_by_num(num), do: Map.fetch!(@base_types, Enum.at(@base_type_num, num) || 0x0D)
  def base_type_by_id(id), do: Map.get(@base_types, id) || @base_type_byte
  def base_types, do: @base_types

  def by_name(name) when is_atom(name) do
    base_type_by_name(name) || Profile.Types.by_name(name)
  end

  def expected(value, expected) do
    if value == expected, do: nil, else: value
  end
end

defmodule ExtFit.Record do
  alias ExtFit.{Field, Types}
  alias __MODULE__.{FitHeader, FitCrc, FitData, FitDefinition}

  @type t :: %FitHeader{} | %FitCrc{} | %FitData{} | %FitDefinition{}

  @doc """
  Gets name for given record based on its message type if possible.
  Gracefully handles unknown messages.
  """
  def name(%FitHeader{}), do: "header"
  def name(%FitCrc{}), do: "header"
  def name(%FitData{def_mesg: def_mesg}), do: name(def_mesg)
  def name(%FitDefinition{mesg_type: nil, global_mesg_num: num}), do: "unknown_#{num}"
  def name(%FitDefinition{mesg_type: mesg}), do: mesg.name

  @doc """
  Returns true if record is unknown.
  """
  def unknown?(%FitDefinition{mesg_type: nil}), do: true
  def unknown?(%FitData{def_mesg: def_mesg}), do: unknown?(def_mesg)
  def unknown?(_), do: false

  @doc """
  Filter records by message name and type.

  Available types: :data | :definition | :any
  """
  def records_by_message(records, name, type \\ :data) when is_list(records) do
    Enum.filter(records, fn
      %FitHeader{} -> false
      %FitCrc{} -> false
      %FitData{} = record -> name(record) == name && type in [:data, :any]
      %FitDefinition{} = record -> name(record) == name && type in [:definition, :any]
    end)
  end

  @doc """
  Filter record's fields by name.
  """
  def fields_by_name(%FitDefinition{field_defs: definitions, dev_field_defs: []}, name)
      when is_atom(name) or is_bitstring(name) do
    Enum.filter(definitions, &(Field.name(&1) == name))
  end

  def fields_by_name(%FitDefinition{field_defs: definitions, dev_field_defs: dev_definitions}, name)
      when is_atom(name) or is_bitstring(name) do
    Enum.filter(dev_definitions ++ definitions, &(Field.name(&1) == name))
  end

  def fields_by_name(%FitData{fields: fields}, name) when is_atom(name) or is_bitstring(name) do
    Enum.filter(fields, &(Field.name(&1) == name))
  end

  @doc """
  Used for inspecting and debugging records. Don't depend on output from it.
  """
  def debug(%FitHeader{} = record) do
    {:header, record.header_size, record.body_size, record.crc}
  end

  def debug(%FitCrc{} = record) do
    {:crc, record.crc, record.matched}
  end

  def debug(%FitDefinition{} = record) do
    {:definition, Map.get(record.mesg_type || %{}, :name), record.local_mesg_num, record.global_mesg_num,
     Enum.map(record.field_defs, &Field.name/1) |> Enum.join(",")}
  end

  def debug(%FitData{} = record) do
    {:data, record.local_mesg_num, Enum.map(record.fields, &Types.FieldData.debug/1)}
  end
end

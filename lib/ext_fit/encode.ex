defmodule ExtFit.Encode do
  @moduledoc """
  Encodes records returned by `ExtFit.Decode` back into FIT binary data.

  Message definitions, local message numbers, byte order, developer fields,
  and compressed timestamp headers are retained. Values are encoded from each
  field's `raw_value`, so decoded records can be filtered or edited without
  reversing unit conversions performed by processors.

  The encoder design was informed by the BSD-3-Clause licensed
  [muktihari/fit](https://github.com/muktihari/fit) encoder by Hikmatulloh Hari
  Mukti. This is an independent Elixir implementation over ExtFit's records.
  """

  import Bitwise

  alias ExtFit.CRC
  alias ExtFit.Field
  alias ExtFit.Record.FitCrc
  alias ExtFit.Record.FitData
  alias ExtFit.Record.FitDefinition
  alias ExtFit.Record.FitHeader
  alias ExtFit.Types.DevFieldDefinition
  alias ExtFit.Types.FieldData
  alias ExtFit.Types.FieldDefinition

  @type reason :: String.t() | term()

  @spec encode([ExtFit.Record.t()]) :: {:ok, binary()} | {:error, reason()}
  def encode(records) when is_list(records) do
    with {:ok, files} <- split_files(records) do
      files
      |> Enum.reduce_while({:ok, []}, fn file, {:ok, encoded} ->
        case encode_file(file) do
          {:ok, binary} -> {:cont, {:ok, [binary | encoded]}}
          {:error, _reason} = error -> {:halt, error}
        end
      end)
      |> case do
        {:ok, encoded} -> {:ok, encoded |> Enum.reverse() |> IO.iodata_to_binary()}
        error -> error
      end
    end
  rescue
    error -> {:error, Exception.message(error)}
  end

  @spec encode!([ExtFit.Record.t()]) :: binary()
  def encode!(records) do
    case encode(records) do
      {:ok, binary} -> binary
      {:error, reason} -> raise "FIT encoding failed: #{inspect(reason)}"
    end
  end

  defp split_files(records) do
    records
    |> Enum.reduce_while({:ok, [], nil}, fn
      %FitHeader{} = header, {:ok, files, nil} ->
        {:cont, {:ok, files, [header]}}

      %FitHeader{}, {:ok, _files, _current} ->
        {:halt, {:error, "encountered a FIT header before the previous file CRC"}}

      record, {:ok, files, current} when is_list(current) ->
        current = [record | current]

        if match?(%FitCrc{}, record) do
          {:cont, {:ok, [Enum.reverse(current) | files], nil}}
        else
          {:cont, {:ok, files, current}}
        end

      _record, {:ok, _files, nil} ->
        {:halt, {:error, "records must start with a FIT header"}}
    end)
    |> case do
      {:ok, files, nil} when files != [] -> {:ok, Enum.reverse(files)}
      {:ok, _files, current} when is_list(current) -> {:error, "FIT records are missing a file CRC"}
      {:ok, [], nil} -> {:error, "no FIT records to encode"}
      error -> error
    end
  end

  defp encode_file([%FitHeader{} = header | records]) do
    body_records = Enum.reject(records, &match?(%FitCrc{}, &1))

    with {:ok, body} <- encode_body(body_records),
         {:ok, file_header} <- encode_header(header, byte_size(body)) do
      without_crc = file_header <> body
      {:ok, without_crc <> <<CRC.calculate(without_crc)::little-unsigned-16>>}
    end
  end

  defp encode_file(_records), do: {:error, "FIT file is missing its header"}

  defp encode_body(records) do
    records
    |> Enum.reduce_while({:ok, []}, fn record, {:ok, encoded} ->
      case encode_record(record) do
        {:ok, binary} -> {:cont, {:ok, [binary | encoded]}}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, encoded} -> {:ok, encoded |> Enum.reverse() |> IO.iodata_to_binary()}
      error -> error
    end
  end

  defp encode_header(header, body_size) when header.header_size in [12, 14] do
    base =
      <<header.header_size, header.proto_ver, header.profile_ver::little-unsigned-16, body_size::little-unsigned-32,
        ".FIT">>

    case header.header_size do
      12 -> {:ok, base}
      14 -> {:ok, base <> <<CRC.calculate(base)::little-unsigned-16>>}
    end
  end

  defp encode_header(header, _body_size), do: {:error, "unsupported FIT header size: #{inspect(header.header_size)}"}

  defp encode_record(%FitDefinition{} = definition), do: encode_definition(definition)
  defp encode_record(%FitData{} = data), do: encode_data(data)
  defp encode_record(record), do: {:error, "unsupported FIT record: #{inspect(record.__struct__)}"}

  defp encode_definition(definition) do
    developer_flag = if definition.dev_field_defs == [], do: 0, else: 0x20
    header = 0x40 ||| developer_flag ||| definition.local_mesg_num
    architecture = if definition.endian == :big, do: 1, else: 0

    standard_fields = Enum.map(definition.field_defs, &encode_field_definition/1)

    developer_fields =
      case definition.dev_field_defs do
        [] -> []
        fields -> [length(fields) | Enum.map(fields, &encode_developer_field_definition/1)]
      end

    global_message = encode_unsigned(definition.global_mesg_num, 2, definition.endian)

    {:ok,
     IO.iodata_to_binary([
       <<header, 0, architecture>>,
       global_message,
       <<length(definition.field_defs)>>,
       standard_fields,
       developer_fields
     ])}
  end

  defp encode_field_definition(%FieldDefinition{} = definition) do
    <<definition.num, definition.size, definition.base_type.id>>
  end

  defp encode_developer_field_definition(%DevFieldDefinition{} = definition) do
    <<definition.num, definition.size, definition.dev_data_index>>
  end

  defp encode_data(%FitData{def_mesg: definition} = data) do
    with {:ok, header} <- encode_data_header(data),
         {:ok, fields} <- encode_defined_fields(data.fields, definition) do
      {:ok, IO.iodata_to_binary([header, fields])}
    end
  end

  defp encode_data_header(data) do
    case compressed_timestamp(data.fields) do
      nil ->
        developer_flag = if data.is_developer_data, do: 0x20, else: 0
        {:ok, <<developer_flag ||| data.local_mesg_num>>}

      offset when data.local_mesg_num in 0..3 ->
        {:ok, <<0x80 ||| data.local_mesg_num <<< 5 ||| (offset &&& 0x1F)>>}

      _offset ->
        {:error, "compressed timestamp requires local message number 0..3"}
    end
  end

  defp compressed_timestamp(fields) do
    Enum.find_value(fields, fn
      %FieldData{field_def: nil, field: field, raw_value: raw_value} ->
        if Field.name(field) == :timestamp, do: raw_value

      _field ->
        nil
    end)
  end

  defp encode_defined_fields(fields, definition) do
    encoded =
      Enum.map(definition.field_defs ++ definition.dev_field_defs, fn field_definition ->
        field_data = Enum.find(fields, &(&1.field_def == field_definition))
        {:ok, binary} = encode_field(field_data, field_definition, definition.endian)
        binary
      end)

    {:ok, IO.iodata_to_binary(encoded)}
  end

  defp encode_field(nil, definition, endian) do
    {:ok, invalid_binary(definition.base_type, definition.size, endian)}
  end

  defp encode_field(%FieldData{} = field_data, definition, endian) do
    raw_value =
      case field_data.raw_value do
        nil -> field_data.encoded_raw_value
        value -> value
      end

    if is_nil(raw_value) do
      {:ok, invalid_binary(definition.base_type, definition.size, endian)}
    else
      encode_raw_value(raw_value, definition, endian)
    end
  end

  defp encode_raw_value(raw_value, definition, endian) do
    base_type = definition.base_type

    case_result =
      case base_type.name do
        :string -> encode_string(raw_value)
        _ -> raw_value |> List.wrap() |> Enum.map(&encode_value(&1, base_type, endian))
      end

    encoded =
      IO.iodata_to_binary(case_result)

    cond do
      byte_size(encoded) == definition.size ->
        {:ok, encoded}

      byte_size(encoded) < definition.size ->
        padding_size = definition.size - byte_size(encoded)
        {:ok, encoded <> invalid_binary(base_type, padding_size, endian)}

      true ->
        {:ok, binary_part(encoded, 0, definition.size)}
    end
  end

  defp encode_string(value) when is_binary(value), do: value <> <<0>>
  defp encode_string(value) when is_list(value), do: IO.iodata_to_binary(value) <> <<0>>

  defp encode_value(value, %{name: name, size: size}, endian) when name in [:sint8, :sint16, :sint32, :sint64] do
    encode_signed(value, size, endian)
  end

  defp encode_value(value, %{name: name, size: size}, endian) when name in [:float32, :float64] do
    encode_float(value, size, endian)
  end

  defp encode_value(value, %{size: size}, endian), do: encode_unsigned(value, size, endian)

  defp encode_unsigned(value, size, :little), do: <<value::little-unsigned-integer-size(size)-unit(8)>>

  defp encode_unsigned(value, size, :big), do: <<value::big-unsigned-integer-size(size)-unit(8)>>

  defp encode_signed(value, size, :little), do: <<value::little-signed-integer-size(size)-unit(8)>>

  defp encode_signed(value, size, :big), do: <<value::big-signed-integer-size(size)-unit(8)>>

  defp encode_float(value, size, :little), do: <<value::little-float-size(size)-unit(8)>>

  defp encode_float(value, size, :big), do: <<value::big-float-size(size)-unit(8)>>

  defp invalid_binary(base_type, size, endian) do
    invalid = encode_value(base_type.invalid, base_type, endian)
    repeats = div(size + byte_size(invalid) - 1, byte_size(invalid))
    invalid |> :binary.copy(repeats) |> binary_part(0, size)
  end
end

defmodule ExtFit.Decode do
  @moduledoc """
  Decodes FIT file into a list of records. If binary data has multiple FIT files
  stiched together it will process them all.

  See `decode/2` for details.
  """

  require Logger
  import Bitwise
  alias ExtFit.{Types, Profile, Processor, Record, Field, Chunk}
  alias ExtFit.Record.{FitHeader, FitCrc, FitDefinition, FitData}
  alias Types.FieldData

  @default_opts %{
    expand_components: true,
    processors: [
      Processor.DefaultProcessor,
      Processor.StandardUnitsProcessor
      # Processor.DebugProcessor
    ]
  }

  @doc "See `decode/2` for details. `decode!` raises an error in case decoding fails."
  def decode!(data, opts \\ []) do
    case decode(data, opts) do
      {:ok, records} ->
        records

      {:error, error, records, rest} when is_list(records) ->
        raise "Decoding failed. Parsed #{length(records)} records. Left #{byte_size(rest)} bytes to process. Error=#{inspect(error)}"
    end
  end

  @doc "See `decode/2` for details"
  @spec decode(binary()) :: {:ok, [Record.t()]} | {:error, String.t(), [Record.t()], binary()}
  def decode(data) when is_binary(data) do
    decode(data, build_options(@default_opts), [])
  end

  @doc """
  Decodes FIT binary data.

  Each record is one of the following types:

    - `ExtFit.Record.FitHeader` - FIT file header
    - `ExtFit.Record.FitDefinition` - definition message
    - `ExtFit.Record.FitData` - data message
    - `ExtFit.Record.FitCrc` - CRC information encoded in the file

  Decode accepts the following options:

    - `expand_components` - (default: `true`) - whether to expand components into separate fields
    - `processors` - (default: `ExtFit.Processor.DefaultProcessor` and `ExtFit.Processor.StandardUnitsProcessor`) -
       list of processors to apply to each record

  ## Examples

      iex> alias ExtFit.Record.{FitHeader, FitDefinition, FitData}
      iex> alias ExtFit.Types.{FieldData, Field}
      iex> {:ok, records} = ExtFit.Decode.decode(File.read!("test/support/files/2023-06-04-garmin-955-running.fit"))
      iex> # Every FIT file starts with a FitHeader
      iex> %FitHeader{body_size: 409401} = hd(records)
      iex> # Then is followed by FileId definition and data
      iex> %FitData{
      ...>   def_mesg: %FitDefinition{mesg_type: %ExtFit.Profile.Messages.FileId{}},
      ...>   fields: [
      ...>     %FieldData{field: %Field{name: :serial_number}, value: 3442024736}
      ...>     | _rest_of_fields
      ...>   ]
      ...> } = Enum.at(records, 2)

  """
  @spec decode(binary(), keyword()) :: {:ok, [Record.t()]} | {:error, String.t(), [Record.t()], binary()}
  def decode(data, opts) when is_binary(data) and is_list(opts) do
    decode(data, build_options(@default_opts, opts), [])
  end

  defp decode(data, opts, collected_records) do
    case decode_fit(data, opts) do
      {:error, error, records, rest} ->
        {:error, error, collected_records ++ records, rest}

      {:ok, records, rest, state} ->
        decode(rest, Map.put(opts, :chunk, state.chunk), collected_records ++ records)

      {:ok, records, _state} ->
        {:ok, collected_records ++ records}
    end
  end

  defp decode_fit(data, opts) do
    {chunk, opts} = Map.pop(opts, :chunk, %Chunk{})

    init_state = %{
      opts: opts,
      chunk: chunk,
      local_num_mapping: %{},
      dev_field_defs: %{},
      accumulators: %{},
      last_timestamp: 0,
      compressed_last_timestamp: 0,
      last_hr_start_timestamp: 0
    }

    {:ok, [], data, init_state}
    |> try_frame(fn {[], rest, state} -> read_fit_header(rest, state) end)
    |> try_frame(fn {[header], rest, state} -> read_data_records(rest, header, state) end)
    |> try_frame(fn {_, rest, state} -> read_fit_crc(rest, state) end)
    |> case do
      {:ok, records, <<>>, state} -> {:ok, Enum.reverse(records), state}
      {:ok, records, rest, state} -> {:ok, Enum.reverse(records), rest, state}
      {:error, error, records, rest} -> {:error, error, Enum.reverse(records), rest}
    end
  end

  defp build_options(default_opts, opts \\ []) do
    # TODO: validate options
    # TODO: add more options(skip crc, skip chunks metadata, etc.), see README.md
    Map.merge(default_opts, Enum.into(opts, %{}))
  end

  # > 12 byte header is considered legacy, using the 14 byte header is preferred
  # > Computing the CRC is optional when using a 14 byte file header
  defp read_fit_header(
         <<header_size, protocol_ver, profile_ver::unit(8)-size(2)-little-integer-signed,
           body_size::unit(8)-size(4)-integer-little-signed, data_type0, data_type1, data_type2, data_type3,
           rest::binary>>,
         state
       ) do
    header_left_size = header_size - 12

    {chunk, next_chunk} = Chunk.mark(state.chunk, header_size)

    header = %FitHeader{
      header_size: header_size,
      proto_ver: protocol_ver,
      profile_ver: profile_ver,
      body_size: body_size,
      type_frame: to_string(List.to_charlist([data_type0, data_type1, data_type2, data_type3])),
      __chunk__: chunk
    }

    if header_size not in [12, 14] do
      Logger.warning("Header is not valid size, still trying to decode: #{inspect(header)}")
    end

    case rest do
      <<header_left::binary-size(header_left_size), rest::binary>> ->
        header =
          case header_left do
            <<0, 0, _unknown_header::binary>> ->
              header

            <<crc::integer-little-size(2)-unit(8), _unknown_header::binary>> ->
              Map.put(header, :crc, %FitCrc{crc: crc})

            <<>> ->
              header
          end

        {:ok, [header], rest, %{state | chunk: next_chunk}}
    end
  end

  defp read_fit_crc(<<0, 0, rest::binary>>, state) do
    {chunk, next_chunk} = Chunk.mark(state.chunk, 2)
    {:ok, [%FitCrc{crc: nil, __chunk__: chunk}], rest, %{state | chunk: next_chunk}}
  end

  defp read_fit_crc(<<crc::integer-little-size(2)-unit(8), rest::binary>>, state) do
    {chunk, next_chunk} = Chunk.mark(state.chunk, 2)
    {:ok, [%FitCrc{crc: crc, __chunk__: chunk}], rest, %{state | chunk: next_chunk}}
  end

  defp read_fit_crc(rest, _), do: {:error, "Mismatch to read fit CRC", nil, rest}

  defp read_data_records(data, %FitHeader{body_size: body_size}, state) do
    # handle gracefully truncated files
    {body, rest} =
      if byte_size(data) < body_size do
        {data, <<>>}
      else
        <<body::binary-size(body_size), rest::binary>> = data
        {body, rest}
      end

    read_data_records(body, [], state)
    |> case do
      {:ok, v, state} -> {:ok, v, rest, state}
      {:error, _err_msg, _records, _rest} = err -> err
    end
  end

  defp read_data_records(<<>>, records, state) do
    {:ok, records, state}
  end

  defp read_data_records(<<header::binary-size(1), rest::binary>>, records, state) do
    case header do
      # definition message
      <<0::1, 1::1, dev_data_flag::1, 0::1, local_mesg_num::integer-little-size(4)-unit(1)>> ->
        record_header = %{is_developer_data: dev_data_flag == 1, local_mesg_num: local_mesg_num}

        case read_def_mesg(rest, record_header, state) do
          {:ok, _def_mesg, _rest, _state} = result -> result
          {:error, reason} -> {:error, reason, records, rest}
        end

      # data message
      <<0::1, 0::1, dev_data_flag::1, 0::1, local_mesg_num::integer-little-size(4)-unit(1)>> ->
        record_header = %{is_developer_data: dev_data_flag == 1, local_mesg_num: local_mesg_num}

        case Map.fetch(state.local_num_mapping, local_mesg_num) do
          {:ok, def_mesg} ->
            read_data_mesg(rest, record_header, def_mesg, state)

          _ ->
            {:error, "Missing mesg num: #{local_mesg_num}", records, rest}
        end

      # compressed header
      <<1::1, local_mesg_num::2, time_offset::unit(1)-size(5)-integer>> ->
        record_header = %{
          is_developer_data: false,
          local_mesg_num: local_mesg_num,
          time_offset: time_offset
        }

        case Map.fetch(state.local_num_mapping, local_mesg_num) do
          {:ok, def_mesg} ->
            read_data_mesg(rest, record_header, def_mesg, state)

          _ ->
            {:error, "Missing mesg num: #{local_mesg_num}", records, rest}
        end

      _ ->
        {:ok, rest, state}
    end
    |> case do
      {:ok, rest, state} ->
        read_data_records(rest, records, state)

      {:ok, record, rest, state} ->
        record = process_record(record, state)
        state = maybe_store_dev_field(record, state)

        read_data_records(rest, [record | records], state)

      err ->
        err
    end
  end

  # Definition Messages: these define the upcoming data messages.
  # A definition message will define a local message type and associate it to a
  # specific FIT message, and then designate the byte alignment and field contents of the
  # upcoming data message.
  defp read_def_mesg(
         <<0::integer, architecture, global_mesg_num::binary-size(2), fields_count, rest::binary>>,
         header,
         state
       ) do
    endian =
      case architecture do
        0 -> :little
        1 -> :big
      end

    global_mesg_num = :binary.decode_unsigned(global_mesg_num, endian)
    # unknown types are expected and will be displayed as unknown in the end
    mesg_type =
      case Profile.Messages.by_num(global_mesg_num) do
        {:error, _} -> nil
        mesg_type -> mesg_type
      end

    {field_defs, rest} =
      0..fields_count
      |> Enum.take_while(&(&1 < fields_count))
      |> Enum.reduce({[], rest}, fn _, {fields, rest} ->
        <<num, size, base_type::binary-size(1), rest::binary>> = rest
        <<_endian::1, _reserved::2, base_type_num::5>> = base_type

        base_type = Types.base_type_by_num(base_type_num)
        # Fallback for misaligned fields
        #   https://github.com/polyvertex/fitdecode/issues/13
        #   https://github.com/dtcooper/python-fitparse/pull/116
        #   https://github.com/GoldenCheetah/GoldenCheetah/issues/3645
        base_type =
          if rem(size, base_type.size) == 0 do
            base_type
          else
            Types.base_type_byte()
          end

        field =
          with fields when is_map(fields) <- Map.get(mesg_type || %{}, :fields),
               {_, field} <- Enum.find(mesg_type.fields, &(elem(&1, 1).num == num)) do
            field
          else
            _ -> nil
          end

        {[
           %Types.FieldDefinition{
             field: field,
             size: size,
             num: num,
             base_type: base_type
           }
           | fields
         ], rest}
      end)

    {dev_field_defs, rest, state} =
      if header.is_developer_data do
        <<fields_count, rest::binary>> = rest

        0..fields_count
        |> Enum.take_while(&(&1 < fields_count))
        |> Enum.reduce({[], rest, state}, fn _, {fields, rest, state} ->
          <<num, size, dev_data_index, rest::binary>> = rest

          field =
            Map.get(state.dev_field_defs, dev_data_index)
            |> Map.fetch!(:fields)
            |> Map.fetch!(num)

          dev_field_def = %Types.DevFieldDefinition{
            size: size,
            num: num,
            dev_data_index: dev_data_index,
            base_type: field.type,
            field: field
          }

          {[dev_field_def | fields], rest, state}
        end)
      else
        {[], rest, state}
      end

    {chunk, next_chunk} = Chunk.mark(state.chunk, 6 + 3 * (length(field_defs) + length(dev_field_defs)))

    def_mesg = %FitDefinition{
      is_developer_data: header.is_developer_data,
      local_mesg_num: header.local_mesg_num,
      endian: endian,
      mesg_type: mesg_type,
      global_mesg_num: global_mesg_num,
      field_defs: Enum.reverse(field_defs),
      dev_field_defs: Enum.reverse(dev_field_defs),
      __chunk__: chunk
    }

    state =
      put_in(state, [:local_num_mapping, header.local_mesg_num], def_mesg)
      |> Map.put(:chunk, next_chunk)

    {:ok, def_mesg, rest, state}
  end

  defp read_def_mesg(_rest, _header, _state) do
    {:error, "couldn't read definition"}
  end

  defp read_data_mesg(data, header, def_mesg, state) do
    {base_fields, state} =
      case Map.get(header, :time_offset) do
        nil ->
          {[], state}

        raw_value when is_number(raw_value) ->
          value = apply_compressed_accumulation(raw_value, state.compressed_last_timestamp, 5)
          state = %{state | compressed_last_timestamp: value}
          field = Profile.Messages.field(:timestamp)

          field_data =
            %FieldData{
              value: value,
              raw_value: raw_value,
              field_def: nil,
              field: field,
              units: field.units
            }

          {
            [field_data],
            state
          }
      end

    {fields, rest, state} =
      (def_mesg.field_defs ++ def_mesg.dev_field_defs)
      |> Enum.reduce({[], data, state}, fn field_def, {fields, rest, state} ->
        size = field_def.size
        <<bin::binary-size(size), rest::binary>> = rest
        raw_value = if(field_def.field, do: read_value(bin, def_mesg.endian, field_def))

        fields = [
          %FieldData{
            field_def: field_def,
            field: field_def.field,
            raw_value: if(raw_value == :invalid, do: nil, else: raw_value)
          }
          | fields
        ]

        cmp_bin =
          cond do
            raw_value == :invalid || raw_value == [] ->
              <<>>

            def_mesg.endian == :big ->
              bin |> :binary.decode_unsigned(:big) |> :binary.encode_unsigned(:little)

            true ->
              bin
          end

        {fields_with_components, state} =
          if state.opts.expand_components do
            unroll_components_into_fields(field_def.field, cmp_bin, def_mesg, state, fields)
          else
            {fields, state}
          end

        {fields_with_components, rest, state}
      end)

    {fields, rest, state} =
      Enum.reverse(fields)
      |> Enum.reduce({[], rest, state}, fn %FieldData{} = fd, {fields_data, rest, state} ->
        {field_data, state} = resolve_field_data(fd, def_mesg, state, fields)

        {[field_data | fields_data], rest, state}
      end)

    all_fields = base_fields ++ Enum.reverse(fields)
    {chunk, next_chunk} = Chunk.mark(state.chunk, 1 + (byte_size(data) - byte_size(rest)))

    {:ok,
     %FitData{
       is_developer_data: header.is_developer_data,
       local_mesg_num: header.local_mesg_num,
       fields: all_fields |> Enum.map(&process_field_data(&1, state)),
       def_mesg: def_mesg,
       __chunk__: chunk
     }, rest, %{state | chunk: next_chunk}}
  end

  defp unroll_components_into_fields(field, bin, def_mesg, state, fields, parent_cmp \\ nil) do
    get_components(field)
    |> Enum.reduce({fields, state}, fn %Types.ComponentField{} = cmp, {fields, state} ->
      cmp_raw_value = extract_component(bin, cmp.bits, cmp.bit_offset)
      {_, cmp_field} = Enum.find(def_mesg.mesg_type.fields, &(elem(&1, 1).num == cmp.num))

      {cmp_raw_value, state} =
        if cmp_raw_value != :invalid && cmp.is_accumulated do
          accumulator_path = [:accumulators, Access.key(def_mesg.global_mesg_num, %{}), Access.key(cmp.num, 0)]
          accumulation_value = get_in(state, accumulator_path)

          new_cmp_raw_value = apply_compressed_accumulation(cmp_raw_value, accumulation_value, cmp.bits)
          state = put_in(state, accumulator_path, new_cmp_raw_value)

          {new_cmp_raw_value, state}
        else
          {cmp_raw_value, state}
        end

      source_cmp = parent_cmp || cmp
      cmp_field = %{cmp_field | offset: source_cmp.offset, scale: source_cmp.scale, units: source_cmp.units}

      {fields, state} = unroll_components_into_fields(cmp_field, bin, def_mesg, state, fields, source_cmp)

      if Field.name(field) == :event_timestamp_12 && cmp_raw_value == :invalid do
        {fields, state}
      else
        {[
           %FieldData{
             field_def: field,
             field: cmp_field,
             parent_field: source_cmp,
             raw_value: if(cmp_raw_value == :invalid, do: nil, else: cmp_raw_value)
           }
           | fields
         ], state}
      end
    end)
  end

  defp resolve_field_data(
         %Types.FieldData{field: field, raw_value: raw_value, value: value} = fd,
         %FitDefinition{endian: endian} = def_mesg,
         state,
         fields
       ) do
    if field do
      {field, parent_field} = resolve_subfield(field, fields, endian)

      value =
        cond do
          !!value ->
            value

          !!raw_value ->
            raw_value
            |> apply_scale_offset(field)

          true ->
            nil
        end

      record_name = Record.name(def_mesg)
      field_name = Field.name(field)

      {value, state} =
        cond do
          fd.field_def && fd.field_def.num == Profile.Messages.field_num(:timestamp) && raw_value ->
            {value,
             state
             |> put_in([:last_timestamp], value)
             |> put_in([:compressed_last_timestamp], raw_value)}

          record_name == :hr && field_name == :event_timestamp_12 ->
            {value, put_in(state, [:last_hr_start_timestamp], state.last_timestamp)}

          record_name == :hr && field_name == :event_timestamp && is_list(value) ->
            {Enum.map(value, &(&1 + state.last_hr_start_timestamp)), state}

          record_name == :hr && field_name == :event_timestamp && is_number(value) ->
            {value + state.last_hr_start_timestamp, state}

          true ->
            {value, state}
        end

      field_data = %Types.FieldData{
        fd
        | value: value,
          field: field,
          units: field.units,
          parent_field: fd.parent_field || parent_field
      }

      {field_data, state}
    else
      {fd, state}
    end
  end

  defp read_value(bin, _endian, %{base_type: %{name: :string}}) do
    consume_string_until_null_or_end(bin)
  end

  defp read_value(bin, endian, %{field: field, base_type: %{size: size, name: name, invalid: invalid}}) do
    values = div(byte_size(bin), size)

    case Map.get(field, :array) || values do
      true ->
        read_values_array(bin, invalid, endian, name, size, values)

      1 ->
        read_single_value(bin, invalid, endian, name, size)

      n when is_integer(n) and n > 1 ->
        read_values_array(bin, invalid, endian, name, size, values)
    end
  end

  defp read_values_array(bin, invalid, endian, name, size, values_count) do
    bin_size = byte_size(bin)

    0..values_count
    |> Enum.filter(&(&1 < values_count))
    |> Enum.reduce({[], bin}, fn start_idx, {values, bin} ->
      if start_idx * size > bin_size do
        {values, <<>>}
      else
        <<v::binary-unit(8)-size(size), rest::binary>> = bin

        read_single_value(v, invalid, endian, name, size)
        |> case do
          :invalid ->
            {values, rest}

          decoded_raw_value ->
            {[decoded_raw_value | values], rest}
        end
      end
    end)
    |> case do
      {[], _} -> nil
      {values, _} -> Enum.reverse(values)
    end
  end

  defp read_single_value(v, invalid, endian, name, size) do
    try do
      case {endian, name} do
        {_, name} when name in ~w(enum sint8 uint8 uint8z byte uint16 uint32 uint64 uint16z uint32z uint64z)a ->
          #   <<v::integer>> = v
          # <<v::unit(8)-size(size)-big-integer-unsigned>> = v
          # <<v::unit(8)-size(size)-little-integer-unsigned>> = v
          :binary.decode_unsigned(v, endian)

        {:big, name} when name in ~w(sint16 sint32 sint64)a ->
          <<v::unit(8)-size(size)-big-integer-signed>> = v
          v

        {:little, name} when name in ~w(sint16 sint32 sint64)a ->
          <<v::unit(8)-size(size)-little-integer-signed>> = v
          v

        {:big, name} when name in ~w(float32 float64)a ->
          <<v::unit(8)-size(size)-big-float>> = v
          v

        {:little, name} when name in ~w(float32 float64)a ->
          <<v::unit(8)-size(size)-little-float>> = v
          v
      end
      |> case do
        ^invalid -> :invalid
        value -> value
      end
    rescue
      _err in MatchError ->
        :invalid
    end
  end

  defp resolve_subfield(%Types.Subfield{} = sf, _values, _endian), do: {sf, nil}
  defp resolve_subfield(%Types.DevField{} = df, _values, _endian), do: {df, nil}

  defp resolve_subfield(field, values, endian) do
    resolve_in_subfields(field.subfields, field, values, endian) || {field, nil}
  end

  defp resolve_in_subfields([], _, _, _), do: nil

  defp resolve_in_subfields([subfield | subfields], field, values, endian) do
    resolve_in_ref_fields(subfield.ref_fields, subfield, field, values, endian) ||
      resolve_in_subfields(subfields, field, values, endian)
  end

  defp resolve_in_ref_fields([], _, _, _, _), do: nil

  defp resolve_in_ref_fields([reffield | reffields], %Types.Subfield{} = subfield, field, values, endian) do
    match =
      values
      |> Enum.find(fn
        %Types.FieldData{field: %{num: num}, raw_value: raw_value} ->
          num == reffield.num && reffield.raw_value == raw_value

        %Types.FieldData{field: %Types.DevFieldDefinition{}} ->
          false

        %Types.FieldData{field: nil} ->
          false
      end)

    if match do
      {subfield, field}
    else
      resolve_in_ref_fields(reffields, subfield, field, values, endian)
    end
  end

  defp try_frame({:ok, result, rest, state}, f) do
    case f.({result, rest, state}) do
      {:ok, new_result, rest, state} ->
        {:ok, new_result ++ result, rest, state}

      {:error, error, new_result, rest} ->
        {:error, error, new_result, rest}
    end
  end

  defp try_frame({:error, _error, _result, _rest} = err, _f) do
    err
  end

  defp consume_string_until_null_or_end(<<>>), do: []
  defp consume_string_until_null_or_end(<<0, _rest::binary>>), do: []

  defp consume_string_until_null_or_end(<<c::utf8, rest::binary>>) do
    [c | consume_string_until_null_or_end(rest)] |> List.to_string()
  end

  # From spec:
  # Scaling and offset defined in Profile.xlsx for the native data
  # fields shall not be applied to the developer data field.
  # Instead, the developer data field shall be logged with full precision
  # and resolution using the appropriate base data type.
  defp apply_scale_offset(value, %Types.DevField{}), do: value
  defp apply_scale_offset(value, _params) when is_bitstring(value), do: value

  defp apply_scale_offset(value, %{offset: offset, scale: scale}) when is_list(value) do
    do_apply_scale_offset(value, offset, scale)
  end

  defp apply_scale_offset(value, %{offset: offset, scale: scale}) do
    do_apply_scale_offset(List.wrap(value), offset, scale) |> hd()
  end

  defp do_apply_scale_offset(values, offset, scale) do
    for value <- values do
      value = if(value && scale, do: 1.0 * value / scale, else: value)
      value = if(value && offset, do: value - offset, else: value)

      value
    end
  end

  defp maybe_store_dev_field(%FitData{fields: _fields, def_mesg: %{mesg_type: %{num: num}}} = mesg, state) do
    cond do
      num == Profile.Types.mesg_num(:developer_data_id) ->
        dev_data_index =
          get_data_mesg_field(mesg, :developer_data_index)
          |> case do
            %{value: value} -> value
            _ -> raise("Missing dev data index")
          end

        application_id =
          get_data_mesg_field(mesg, :application_id)
          |> case do
            %{value: value} -> value
            _ -> nil
          end

        upsert_dev_field(state, dev_data_index, %{application_id: application_id}, true)

      num == Profile.Types.mesg_num(:field_description) ->
        desc =
          ~w(developer_data_index field_definition_number
                fit_base_type_id field_name units native_field_num)a
          |> Enum.reduce(%{}, fn name, desc ->
            value = (get_data_mesg_field(mesg, name) || %{}) |> Map.get(:value)
            Map.put(desc, name, value)
          end)

        upsert_dev_field(state, desc.developer_data_index, %{
          fields: %{
            desc.field_definition_number => %Types.DevField{
              dev_data_index: desc.developer_data_index,
              name: desc.field_name,
              num: desc.field_definition_number,
              units: desc.units,
              native_field_num: desc.native_field_num,
              type: Types.base_type_by_id(desc.fit_base_type_id)
            }
          }
        })

      true ->
        state
    end
  end

  # unknown data mesg
  defp maybe_store_dev_field(%FitData{def_mesg: %{mesg_type: nil}}, state), do: state
  defp maybe_store_dev_field(%FitDefinition{}, state), do: state

  defp get_data_mesg_field(%FitData{fields: fields}, match) do
    fields
    |> Enum.find(fn
      %{field: %{name: name}} ->
        name == match

      _ ->
        false
    end)
  end

  defp get_components(nil), do: []
  defp get_components(%{components: components}), do: components
  defp get_components(%Types.DevField{}), do: []

  defp upsert_dev_field(state, dev_data_index, params), do: upsert_dev_field(state, dev_data_index, params, false)
  defp upsert_dev_field(_state, nil, _params, _overwrite), do: raise("Missing dev data index")

  defp upsert_dev_field(state, dev_data_index, params, overwrite) do
    existing_data = if(!overwrite, do: Map.get(state.dev_field_defs, dev_data_index)) || %{fields: %{}}

    data =
      existing_data
      |> Map.put(:dev_data_index, dev_data_index)
      |> Map.merge(params)
      |> Map.put(:fields, Map.merge(existing_data.fields, Map.get(params, :fields, %{})))

    put_in(state, [:dev_field_defs, dev_data_index], data)
  end

  @bit_mask [1, 2, 4, 8, 16, 32, 64, 128]
  # Extracts component value given bitstring
  defp extract_component(input, bits, offset) when is_number(bits) and bits > 0 do
    skipped_bytes = div(offset, 8)

    if skipped_bytes >= byte_size(input) do
      :invalid
    else
      <<_skipped::binary-size(^skipped_bytes)-unit(8), bytes::binary>> = input

      0..(bits - 1)
      |> Enum.reduce({0, bytes}, fn pos, {acc, bytes} ->
        full_offset = offset + pos
        nbit = rem(full_offset, 8)

        with <<byte::8, rest::binary>> <- bytes do
          acc = acc ||| (byte &&& Enum.at(@bit_mask, nbit)) >>> nbit <<< pos

          if nbit == 7 do
            {acc, rest}
          else
            {acc, bytes}
          end
        else
          _ -> {acc, nil}
        end
      end)
      |> elem(0)
    end
  end

  defp apply_compressed_accumulation(raw_value, accumulation, nbits) do
    max_value = 1 <<< nbits
    max_mask = max_value - 1
    base_value = raw_value + (accumulation &&& bnot(max_mask))

    if raw_value < (accumulation &&& max_mask) do
      base_value + max_value
    else
      base_value
    end
  end

  defp process_record(record, %{opts: %{processors: processors}}) do
    Enum.reduce(processors, record, & &1.process_record(&2))
  end

  defp process_field_data(field_data, %{opts: %{processors: processors}}) do
    Enum.reduce(processors, field_data, & &1.process_field_data(&2))
  end
end

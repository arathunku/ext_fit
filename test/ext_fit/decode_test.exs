defmodule ExtFit.DecodeTest do
  use ExUnit.Case, async: true
  doctest ExtFit.Decode

  require Logger
  alias ExtFit.{Decode, Field, Record, Chunk}
  alias ExtFit.Record.{FitHeader, FitCrc, FitDefinition, FitData}

  @files Path.join(__DIR__, "../support/files") |> Path.expand()

  test "reads Activity.fit file" do
    filename = "Activity.fit"
    file = read_file(filename)

    {:ok, records} = Decode.decode(file)

    assert hd(records) == %FitHeader{
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 12},
             header_size: 12,
             proto_ver: 16,
             profile_ver: 100,
             body_size: 757,
             type_frame: ".FIT"
           }

    assert List.last(records) == %FitCrc{crc: 41429, __chunk__: %Chunk{index: 33, offset: 769, size: 2}}
  end

  test "reads Settings.fit file" do
    filename = "Settings.fit"
    file = read_file(filename)

    {:ok, records} = Decode.decode(file)
    header = hd(records)

    assert header == %FitHeader{
             header_size: 14,
             type_frame: ".FIT",
             proto_ver: 16,
             profile_ver: 1300,
             body_size: 1271,
             crc: nil,
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 14}
           }
  end

  test "reads DeveloperData.fit" do
    filename = "DeveloperData.fit"
    file = read_file(filename)

    {:ok, records} = Decode.decode(file)
    header = hd(records)

    assert header == %FitHeader{
             body_size: 162,
             crc: %FitCrc{crc: 53438, matched: nil},
             header_size: 14,
             profile_ver: 1640,
             proto_ver: 32,
             type_frame: ".FIT",
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 14}
           }
  end

  test "reads avg-speed.fit" do
    filename = "avg-speed.fit"
    file = read_file(filename)

    {:ok, records} = Decode.decode(file)
    header = hd(records)
    data_records = Enum.drop(records, 1)

    assert header == %FitHeader{
             body_size: 715_710,
             crc: %FitCrc{crc: 23070, matched: nil},
             header_size: 14,
             profile_ver: 2027,
             proto_ver: 32,
             type_frame: ".FIT",
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 14}
           }

    session = Enum.find(data_records, &(Record.name(&1) == :session && &1.__struct__ == FitData))
    avg_speed = session.fields |> Enum.find(&(Field.name(&1) == :avg_speed))
    assert avg_speed.value == 5.86
  end

  test "compressed fields compressed-speed-distance.fit" do
    filename = "compressed-speed-distance.fit"
    file = read_file(filename)

    {:ok, records} = Decode.decode(file)
    header = hd(records)
    data_records = Enum.drop(records, 1)

    assert header == %FitHeader{
             body_size: 5771,
             crc: nil,
             header_size: 12,
             profile_ver: 57,
             proto_ver: 0,
             type_frame: ".FIT",
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 12}
           }

    compressed_speed_distance = data_records |> Enum.drop(26) |> Enum.take(3)

    values =
      Enum.map(compressed_speed_distance, fn
        %FitData{} = record ->
          record.fields |> Enum.filter(&(Field.name(&1) in ~w(speed distance cadence)a))

        _ ->
          nil
      end)
      |> Enum.map(fn fields -> Enum.map(fields, &{Field.name(&1), &1.value}) end)

    assert values == [
             [{:speed, 3.54}, {:distance, 0.0}, {:cadence, nil}],
             [{:speed, 3.55}, {:distance, 14.25}, {:cadence, 88}],
             [{:speed, 0.0}, {:distance, 18.875}, {:cadence, 34}]
           ]
  end

  test "ensure compressed values are shifted and scaled - event_timestamp.fit" do
    filename = "event_timestamp.fit"
    file = read_file(filename)
    {:ok, records} = Decode.decode(file)

    assert length(records) == 6250

    assert hd(records) == %FitHeader{
             body_size: 58949,
             __chunk__: %ExtFit.Chunk{index: 0, offset: 0, size: 14},
             crc: %ExtFit.Record.FitCrc{crc: 46851, matched: nil},
             header_size: 14,
             profile_ver: 2032,
             proto_ver: 16,
             type_frame: ".FIT"
           }

    field_data_values =
      Enum.at(records, -254)
      |> Map.fetch!(:fields)
      |> Enum.map(&{Field.name(&1), &1.value})
      |> Enum.filter(&(elem(&1, 0) == :event_timestamp))
      |> Enum.map(fn {k, v} -> {k, DateTime.truncate(v, :second)} end)

    assert field_data_values ==
             [
               {:event_timestamp, ~U[2017-06-13 14:44:07Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:08Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:08Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:09Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:09Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:10Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:10Z]},
               {:event_timestamp, ~U[2017-06-13 14:44:11Z]}
             ]
  end

  test "ensure decoding continues on mismatched field size" do
    records =
      "coros-pace-2-cycling-misaligned-fields.fit"
      |> read_file()
      |> Decode.decode!()

    assert length(records) == 11327
  end

  test "reads developer types - developer-types-sample.fit" do
    records =
      "developer-types-sample.fit"
      |> read_file()
      |> Decode.decode!()

    assert length(records) == 3455

    %FitDefinition{dev_field_defs: [dev_field | _]} = Enum.at(records, 19)

    assert dev_field.field.name == "Form Power"
    assert dev_field.field.units == "Watts"
    assert dev_field.field.native_field_num == nil
  end

  test "reads invalid strava product strava-android-app-201.10-b1218918.fit file" do
    {:error, _message, records, _rest} =
      "strava-android-app-201.10-b1218918.fit"
      |> read_file()
      |> Decode.decode()

    assert length(records) == 503

    assert field_data_values(Enum.slice(records, 1..1)) == [
             [
               {:manufacturer, 265},
               {:product, 102},
               {:type, 4},
               {:time_created, ~U[2021-09-27 15:13:02Z]}
             ]
           ]
  end

  test "match values for GPS" do
    records =
      "2023-06-04-garmin-955-running.fit"
      |> read_file()
      |> Decode.decode!()

    assert length(records) == 16478

    %FitData{fields: fields} = Enum.at(records, 606)

    result =
      fields
      |> Enum.map(&{Field.name(&1), &1.value || &1.raw_value})
      |> Enum.sort_by(&elem(&1, 0))

    assert result == [
             {:accumulated_power, 57288},
             {:activity_type, 1},
             {:cadence, 92},
             {:cycle_length16, 0.0},
             {:distance, 611.89},
             {:enhanced_altitude, 175.20000000000005},
             {:enhanced_speed, 3.723},
             {:fractional_cadence, 0.0},
             {:heart_rate, 147},
             {:position_lat, 50.2264201361686},
             {:position_long, 9.350256649777293},
             {:power, 300},
             {:stance_time, 227.0},
             {:stance_time_balance, nil},
             {:stance_time_percent, nil},
             {:step_length, 1214.0},
             {:temperature, 33},
             {:timestamp, ~U[2023-06-04 13:33:15Z]},
             {:vertical_oscillation, 87.3},
             {:vertical_ratio, 7.19},
             {"unknown_107", nil},
             {"unknown_134", nil},
             {"unknown_135", nil},
             {"unknown_136", nil},
             {"unknown_137", nil},
             {"unknown_138", nil},
             {"unknown_140", nil}
           ]
  end

  test "marks chunks correctly" do
    records =
      "2023-06-04-garmin-955-running.fit"
      |> read_file()
      |> Decode.decode!()

    inital_chunks = Enum.take(records, 10) |> Enum.map(& &1.__chunk__)
    %FitCrc{__chunk__: last_chunk} = List.last(records)

    assert inital_chunks == [
             %Chunk{index: 0, offset: 0, size: 14},
             %Chunk{index: 1, offset: 14, size: 27},
             %Chunk{index: 2, offset: 41, size: 20},
             %Chunk{index: 3, offset: 61, size: 21},
             %Chunk{index: 4, offset: 82, size: 26},
             %Chunk{index: 5, offset: 108, size: 18},
             %Chunk{index: 6, offset: 126, size: 9},
             %Chunk{index: 7, offset: 135, size: 30},
             %Chunk{index: 8, offset: 165, size: 21},
             %Chunk{index: 9, offset: 186, size: 21}
           ]

    assert last_chunk == %Chunk{index: 16477, offset: 409_415, size: 2}
  end

  describe "options" do
    test "skips component expansion" do
      filename = "event_timestamp.fit"
      file = read_file(filename)
      {:ok, records} = Decode.decode(file, expand_components: false)

      event_timestamp_values =
        Enum.at(records, -254)
        |> Map.fetch!(:fields)
        |> Enum.map(&{Field.name(&1), &1.value})
        |> Enum.filter(&(elem(&1, 0) == :event_timestamp))

      event_timestamp_12_values =
        Enum.at(records, -254)
        |> Map.fetch!(:fields)
        |> Enum.map(&{Field.name(&1), &1.value})
        |> Enum.filter(&(elem(&1, 0) == :event_timestamp_12))

      assert event_timestamp_values == []

      assert event_timestamp_12_values == [
               {:event_timestamp_12, [136, 231, 149, 50, 155, 208, 222, 110, 10, 106, 98, 66]}
             ]
    end
  end

  defp read_file(name) do
    path = Path.join(@files, name)
    {:ok, file} = File.open(path, [:binary, :read])
    data = IO.binread(file, :eof)
    File.close(file)

    data
  end

  defp field_data_values(records) when is_list(records) do
    records
    |> Enum.map(&field_data_values/1)
  end

  defp field_data_values(%{fields: fields}) do
    fields
    |> Enum.map(&{Field.name(&1), &1.value})
  end

  defp field_data_values(%{field_defs: defs, dev_field_defs: dev_field_defs}),
    do: Enum.map(defs ++ dev_field_defs, &{Field.name(&1), to_string(div(&1.size, &1.base_type.size))})

  defp field_data_values(%{crc: crc}), do: %{crc: crc}
end

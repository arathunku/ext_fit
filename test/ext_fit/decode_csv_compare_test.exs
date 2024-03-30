defmodule ExtFit.DecodeCsvCompareTest do
  use ExUnit.Case, async: true

  alias ExtFit.Decode
  alias ExtFit.Field
  alias ExtFit.Processor
  alias ExtFit.Record
  alias ExtFit.Record.FitCrc
  alias ExtFit.Record.FitHeader

  require Logger

  @files __DIR__ |> Path.join("../support/files") |> Path.expand()

  @test_focus_file System.get_env("EXT_FIT_FOCUS_FILE")

  if @test_focus_file do
    Logger.warning("Single file under test: #{@test_focus_file}")
  end

  @processors [Processor.DefaultProcessor]

  @test_valid_files [
    "2023-06-04-garmin-955-running.fit",
    "2013-02-06-12-11-14.fit",
    "2015-10-13-08-43-15.fit",
    "20170518-191602-1740899583.fit",
    "Activity.fit",
    "DeveloperData.fit",
    "Edge810-Vector-2013-08-16-15-35-10.fit",
    "MonitoringFile.fit",
    "Settings.fit",
    "Settings2.fit",
    "WeightScaleMultiUser.fit",
    "WeightScaleSingleUser.fit",
    "WorkoutCustomTargetValues.fit",
    "WorkoutIndividualSteps.fit",
    # next file is skipped, it reports target_hr_zone insteat of repeat_hr, which doesn't make
    # sense at all for the reported value which is 80 (% or bpm), zone is in 1-5 format
    # "WorkoutRepeatGreaterThanStep.fit",
    "WorkoutRepeatSteps.fit",
    "activity-large-fenxi2-multisport.fit",
    "activity-settings.fit",
    "activity-small-fenix2-run.fit",
    "antfs-dump.63.fit",
    "avg-speed.fit",
    # this file is skipped, distance values from CSV are not correct
    # easy to check that by checking total_distance and then distance in records
    # "compressed-speed-distance.fit",
    "coros-pace-2-cycling-misaligned-fields.fit",
    "developer-types-sample.fit",
    "event_timestamp.fit",
    "garmin-edge-500-activity.fit",
    "garmin-edge-820-bike.fit",
    "garmin-fenix-5-bike.fit",
    "garmin-fenix-5-run.fit",
    "garmin-fenix-5-walk.fit",
    "garmin-fr935-cr.fit",
    # this must be skipped, somehow in CSV, garmin is accumulating invalid values
    # "null_compressed_speed_dist.fit",
    "sample-activity-indoor-trainer.fit",
    "sample-activity.fit"
    # skip strava, it's invalid at the end, around 503 records are only read
    # "strava-android-app-201.10-b1218918.fit"
  ]

  # local_timestamp -> it's converted to timezone by default but fit's CSV is timestamp int
  @dropped_fields ~w(local_timestamp unknown)

  @test_valid_files
  |> Enum.filter(&(!@test_focus_file || &1 == @test_focus_file))
  |> Enum.map(fn filename ->
    test "ensures #{filename} is matching output from other tools" do
      filename = unquote(filename)

      records = filename |> read_file() |> Decode.decode!(processors: @processors)
      record_to_compare = Enum.filter(records, &(&1.__struct__ not in [FitCrc, FitHeader]))
      skipped_records = length(records) - length(record_to_compare)

      # Firt row is headers
      fit2csv = filename |> get_fit2csv_data() |> Enum.drop(1)

      fit2csv_count = length(fit2csv)
      cmp_rows = Enum.min([fit2csv_count, 300])

      assert length(records) - skipped_records == length(fit2csv)

      ext_fit_records = Enum.take(record_to_compare, cmp_rows)
      fit2csv_records = Enum.take(fit2csv, cmp_rows)

      ext_fit_records
      |> Enum.zip(fit2csv_records)
      |> Enum.with_index()
      |> Enum.map(fn {{record, row}, idx} ->
        record_values =
          record
          |> field_data_values()
          |> Enum.map(fn {name, value} -> {normalize_name(name), normalize_value(value)} end)
          |> Enum.filter(fn {name, _} -> name not in @dropped_fields end)
          |> Enum.reduce([], fn {name, value}, acc ->
            if Enum.find(acc, &(elem(&1, 0) == name)) do
              Enum.map(acc, fn
                {^name, found_value} ->
                  {name, [found_value, value] |> List.flatten() |> normalize_value()}

                elem ->
                  elem
              end)
            else
              [{name, value} | acc]
            end
          end)
          |> Enum.sort_by(& &1)

        row_values =
          row
          |> Enum.drop(3)
          |> Enum.chunk_every(3)
          |> Enum.filter(&(hd(&1) != ""))
          |> Enum.filter(fn [name, _, _] -> normalize_name(name) not in @dropped_fields end)
          |> Enum.map(fn [name, value, _units] ->
            name = normalize_name(name)

            known_record_value =
              record_values
              |> Enum.find(&(elem(&1, 0) == name))
              |> case do
                {^name, value} -> value
                _ -> :unknown
              end

            # additonal mapping, sometime CSV has additional values at the end of array
            # null bytes / invalid values to mark "the end", we don't care about that when reading
            value =
              filename
              |> normalize_fit2csv_value(name, value)
              |> case do
                [^known_record_value | _] -> known_record_value
                value -> value
              end

            {name, value}
          end)
          |> Enum.sort_by(& &1)

        if record_values != row_values do
          Logger.error("Failure for row: #{idx} #{Record.name(record)}")
        end

        assert record_values == row_values
      end)
    end
  end)

  defp read_file(name) do
    path = Path.join(@files, name)
    {:ok, file} = File.open(path, [:binary, :read])
    data = IO.binread(file, :eof)
    File.close(file)

    data
  end

  defp field_data_values(records) when is_list(records) do
    Enum.map(records, &field_data_values/1)
  end

  defp field_data_values(%{fields: fields}) do
    Enum.map(fields, &{Field.name(&1), &1.value})
  end

  defp field_data_values(%{field_defs: defs, dev_field_defs: dev_field_defs}),
    do: Enum.map(defs ++ dev_field_defs, &{Field.name(&1), to_string(div(&1.size, &1.base_type.size))})

  defp field_data_values(%{crc: crc}), do: %{crc: crc}

  defp get_fit2csv_data(filename) do
    filename = String.replace_suffix(filename, ".fit", ".csv")

    @files
    |> Path.join(filename)
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.to_list()
  end

  def normalize_name("unknown_" <> _), do: "unknown"
  def normalize_name(name), do: to_string(name)

  def normalize_value(v) when is_number(v), do: normalize_value(to_string(v))

  def normalize_value(v) when is_list(v) do
    v
    |> Enum.map(&normalize_value/1)
    |> Enum.filter(&(&1 != ""))
    |> case do
      [] ->
        ""

      [v] ->
        v

      list ->
        list
    end
  end

  def normalize_value(%DateTime{} = dt),
    do: dt |> DateTime.truncate(:second) |> DateTime.to_iso8601() |> normalize_value()

  def normalize_value(%NaiveDateTime{} = ndt), do: ndt |> DateTime.from_naive!("Etc/UTC") |> normalize_value()

  def normalize_value(nil), do: ""

  def normalize_value(v) when is_bitstring(v) do
    v = String.downcase(v)

    try_result =
      try do
        v
        |> String.to_float()
        |> Decimal.from_float()
        |> Decimal.round(2)
        |> Decimal.to_string()
      rescue
        ArgumentError ->
          try do
            v
            |> String.to_integer()
            |> Decimal.round(2)
            |> Decimal.to_string()
          rescue
            ArgumentError -> v
          end
      end

    case try_result do
      "0.00" -> ""
      "0" -> "0"
      "65535.00" -> ""
      "655.35" -> ""
      "65.54" -> ""
      "40.95" -> ""
      v -> v
    end
  end

  def normalize_fit2csv_value(_filename, _field_name, value), do: normalize_fit2csv_value(value)

  defp normalize_fit2csv_value(value) do
    value
    |> normalize_value()
    |> String.trim_trailing("||")
    |> String.split("|")
    |> normalize_value()
  end
end

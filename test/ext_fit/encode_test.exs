defmodule ExtFit.EncodeTest do
  use ExUnit.Case, async: true

  alias ExtFit.Decode
  alias ExtFit.Encode
  alias ExtFit.Field
  alias ExtFit.Record.FitData

  @files Path.expand("../support/files", __DIR__)

  @lossless_files ~w(
    Activity.fit
    DeveloperData.fit
    MonitoringFile.fit
    Settings2.fit
    WeightScaleMultiUser.fit
    WorkoutCustomTargetValues.fit
    activity-large-fenxi2-multisport.fit
    activity-small-fenix2-run.fit
    developer-types-sample.fit
    garmin-edge-500-activity.fit
    null_compressed_speed_dist.fit
    sample-activity.fit
  )

  for filename <- @lossless_files do
    path = Path.join(@files, filename)

    filename = Path.basename(path)

    @tag fit_fixture: filename
    test "losslessly re-encodes #{filename}" do
      original = File.read!(unquote(path))
      records = Decode.decode!(original)

      assert Encode.encode!(records) == original
    end
  end

  test "recalculates a zero header CRC" do
    original = File.read!(Path.join(@files, "Settings.fit"))
    assert <<_header::binary-size(12), 0, 0, _rest::binary>> = original

    encoded = original |> Decode.decode!() |> Encode.encode!()

    refute encoded == original
    assert {:ok, _records} = Decode.decode(encoded)
    refute binary_part(encoded, 12, 2) == <<0, 0>>
  end

  test "encodes edited raw field values" do
    original = File.read!(Path.join(@files, "activity-small-fenix2-run.fit"))
    records = Decode.decode!(original)

    edited =
      Enum.map(records, fn
        %FitData{} = record ->
          fields =
            Enum.map(record.fields, fn field_data ->
              if Field.name(field_data) == :heart_rate and field_data.field_def do
                %{field_data | raw_value: 123, value: 123}
              else
                field_data
              end
            end)

          %{record | fields: fields}

        record ->
          record
      end)

    refute Encode.encode!(edited) == original

    heart_rates =
      edited
      |> Encode.encode!()
      |> Decode.decode!()
      |> Enum.flat_map(fn
        %FitData{fields: fields} -> Enum.filter(fields, &(Field.name(&1) == :heart_rate))
        _record -> []
      end)

    assert heart_rates != []
    assert Enum.all?(heart_rates, &(&1.raw_value == 123))
  end
end

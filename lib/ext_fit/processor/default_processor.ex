defmodule ExtFit.Processor.DefaultProcessor do
  @moduledoc """

  Converts some of FIT types into more useful and standard units.

  * Garmin "timestamps" into Elixir DateTime
  * Garmin "local_timestamps" into Elixir NaiveDateTime

  Enabled by default.
  """

  @behaviour ExtFit.Processor

  alias ExtFit.Field
  alias ExtFit.Record.FitData
  alias ExtFit.Types.BaseType
  alias ExtFit.Types.FieldData
  alias ExtFit.Types.FieldType

  # Datetimes (uint32) represent seconds since this ``FIT_UTC_REFERENCE``
  # (unix timestamp for UTC 00:00 Dec 31 1989).
  @fit_utc_reference_s 631_065_600

  # ``date_time`` typed fields for which value is below ``FIT_DATETIME_MIN``
  # represent the number of seconds elapsed since device power on.
  # @fit_datetime_min 0x10000000

  def process_record(%FitData{fields: fields, def_mesg: %{mesg_type: %{name: :hr}}} = fdm) do
    if Enum.find(fields, &(Field.name(&1) == :event_timestamp_12)) do
      fields =
        Enum.map(fields, fn
          %{field: %{name: :event_timestamp}, value: value} = field when is_number(value) ->
            fraction =
              value
              |> Decimal.from_float()
              |> Decimal.round(6)
              |> Cldr.Digits.fraction_as_integer()

            value =
              (@fit_utc_reference_s + value)
              |> trunc()
              |> DateTime.from_unix!()
              |> Map.put(:microsecond, {fraction, 6})

            %{field | units: nil, value: value}

          field ->
            field
        end)

      %{fdm | fields: fields}
    else
      fdm
    end
  end

  def process_record(record), do: record

  def process_field_data(%FieldData{value: nil} = fd), do: fd

  def process_field_data(%FieldData{value: value} = fd) do
    %{
      fd
      | value: process_field_value(value, fd.field),
        value_label:
          case fd do
            %{field: %{type: %{values: %{^value => %{name: name}}}}} ->
              name

            %{values: %{^value => %{name: name}}} ->
              name

            _ ->
              nil
          end
    }
  end

  defp process_field_value(value, %{type: %FieldType{name: :date_time}}) do
    DateTime.from_unix!(@fit_utc_reference_s + (value || 0))
  end

  defp process_field_value(value, %{type: %FieldType{name: :local_date_time}}) do
    (@fit_utc_reference_s + (value || 0))
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end

  defp process_field_value(value, %{type: %FieldType{}}), do: value
  defp process_field_value(value, %{type: %BaseType{}}), do: value
end

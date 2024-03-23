defmodule ExtFit.Processor.StandardUnitsProcessor do
  @moduledoc """

  Additional units processor for nicer out of box DX when working with FIT files.

  * `semicircles` to `deg`

  Enabled by default.
  """

  @behaviour ExtFit.Processor

  alias ExtFit.Types.FieldData

  def process_record(record), do: record

  @semicircles_denominator 2 ** 31
  def process_field_data(%FieldData{value: value, field: %{units: "semicircles"}} = fd) when is_number(value) do
    %{fd | value: value * 180.0 / @semicircles_denominator, units: "deg"}
  end

  # Convert all speed/pace units into the same format?
  def process_field_data(%FieldData{} = fd), do: fd
end

defmodule ExtFit.Processor do
  @moduledoc """
  Defines behaviour for processing records and field data.
  """

  alias ExtFit.Record.FitData
  alias ExtFit.Record.FitDefinition
  alias ExtFit.Types.FieldData

  @doc """
  Called for each record.
  """
  @type fit_record :: FitData.t() | FitDefinition.t()
  @callback process_record(arg :: fit_record) :: fit_record

  @doc """
  Called for each field data.
  """
  @type field_data :: FieldData.t()
  @callback process_field_data(arg :: field_data) :: field_data
end

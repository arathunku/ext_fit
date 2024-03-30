defmodule ExtFit.Processor.DebugProcessor do
  @moduledoc """
  Inspects and prints information about each processed record. Helpul for debugging. Disabled by default.
  """

  @behaviour ExtFit.Processor

  alias ExtFit.Record, warn: false
  alias ExtFit.Types.FieldData

  require Logger

  @log_index []
  @inspect_opts [width: :infinity, limit: :infinity, charlists: :as_lists]

  def process_record(%{__chunk__: %{index: index}} = record) do
    if index in @log_index do
      Logger.debug("Record: #{inspect(record, @inspect_opts)}")
      # Record.debug(record)
    end

    record
  end

  def process_field_data(%FieldData{} = fd), do: fd
end

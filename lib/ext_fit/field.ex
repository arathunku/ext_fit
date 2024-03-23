defmodule ExtFit.Field do
  @moduledoc """
  Helper mExtFit.Fieldethods for working with fields of various types - `t:ExtFit.Field.field/0`
  """

  alias ExtFit.Types.BaseType

  @doc """
  Returns field's name. If field is known it will return its atom name, if field is unknown
  it returns `"unknown_\#{num}"`.
  """
  @type field :: ExtFit.Types.Subfield.t() | ExtFit.Types.Field.t() | ExtFit.Types.FieldData.t() | ExtFit.Types.FieldDefinition.t() | ExtFit.Types.DevFieldDefinition.t() 

  @spec name(field) :: atom() | String.t()
  def name(%{field: %{name: name}} = _field), do: name
  def name(%{field: nil, num: num}), do: "unknown_#{num}"
  def name(%{field_def: %{} = field_def}), do: name(field_def)
  def name(%{name: name}) when is_bitstring(name) or is_atom(name), do: name

  @doc """
  Check if field is unknown
  """
  @spec unknown?(field) :: boolean()
  def unknown?(%{field: nil} = _field), do: true
  def unknown?(_), do: false

  @doc """
  Recursively searches for base type within a field
  """
  @spec base_type(field) :: ExtFit.Types.BaseType.t()
  def base_type(%BaseType{} = field), do: field
  def base_type(%{base_type: base_type}), do: base_type
  def base_type(%{type: type}), do: base_type(type)
end

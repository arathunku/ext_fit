defmodule ExtFit.Profile do
  @moduledoc false

  alias ExtFit.Types

  @accumulating_types_attrs [:extfit_types]
  @accumulating_messages_attrs [:extfit_messages]
  @accumulating_fields_attr :extfit_acc_fields

  defmacro __using__(:types) do
    quote do
      import ExtFit.Profile, only: [type: 3, type: 4]

      Enum.each(unquote(@accumulating_types_attrs), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      @before_compile {unquote(__MODULE__), :__compile_types_callbacks__}
    end
  end

  defmacro __using__(:messages) do
    quote do
      import ExtFit.Profile, only: [message: 2]

      Enum.each(unquote(@accumulating_messages_attrs), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      @before_compile {unquote(__MODULE__), :__compile_messages_callbacks__}
    end
  end

  defmacro type(name, type, values) do
    quote bind_quoted: [name: name, type: type, values: values, opts: []] do
      ExtFit.Profile.__type__(name, type, values, opts, __ENV__)
    end
  end

  defmacro type(name, type, values, opts) when is_atom(name) and is_atom(type) and is_list(values) do
    quote bind_quoted: [name: name, type: type, values: values, opts: opts] do
      ExtFit.Profile.__type__(name, type, values, opts, __ENV__)
    end
  end

  defmacro message(name, do: block) do
    mod =
      name
      |> Atom.to_string()
      |> Macro.camelize()
      |> String.to_atom()

    ast = ExtFit.Profile.__message_mod__(mod, name, block)

    content =
      quote do
        unquote(ast)
      end

    {:module, module, _, _} =
      Module.create(Module.concat(__CALLER__.module, mod), content, Macro.Env.location(__ENV__))

    quote do
      ExtFit.Profile.__message__(unquote(module), unquote(name), __ENV__)
    end
  end

  defmacro field(num, name, type) do
    quote bind_quoted: [name: name, type: type, num: num, opts: []] do
      ExtFit.Profile.__field__(__MODULE__, num, name, type, opts)
    end
  end

  defmacro field(num, name, type, opts) do
    quote bind_quoted: [name: name, type: type, num: num, opts: opts] do
      ExtFit.Profile.__field__(__MODULE__, num, name, type, opts)
    end
  end

  # Opts are accepted but at this moment they're not used later anywhere
  def __type__(name, type, values, _opts, %Macro.Env{module: mod}) do
    types = mod |> Module.get_attribute(:extfit_types)

    if Keyword.has_key?(types, name) do
      raise ArgumentError, "the type #{inspect(name)} is already set"
    end

    field_type = %Types.FieldType{
      name: name,
      base_type: Types.base_type_by_name(type),
      values:
        Enum.map(values, fn
          {num, value_name, _} ->
            {num, %Types.FieldTypeValue{num: num, name: value_name}}

          {num, value_name} ->
            {num, %Types.FieldTypeValue{num: num, name: value_name}}
        end)
        |> Enum.into(%{})
    }

    Module.put_attribute(mod, :extfit_types, field_type)
  end

  def __message__(message_mod, name, %Macro.Env{module: mod}) do
    messages = mod |> Module.get_attribute(:extfit_messages)

    if Keyword.has_key?(messages, name) do
      raise ArgumentError, "the message #{inspect(name)} is already set"
    end

    Module.put_attribute(mod, :extfit_messages, {name, message_mod})
  end

  def __message_mod__(_mod, name, block) do
    {num, _} =
      Types.by_name(:mesg_num).values
      |> Enum.find({:error, {:value_not_found, name}}, fn {_, v} -> v.name == to_string(name) end)

    quote do
      import ExtFit.Profile, only: [field: 4, field: 3]

      Module.register_attribute(__MODULE__, :extfit_struct_fields, accumulate: false)
      Module.register_attribute(__MODULE__, unquote(@accumulating_fields_attr), accumulate: true)

      @before_compile {unquote(__MODULE__), :__compile_message_mod_callbacks__}

      @num unquote(num)
      @name unquote(name)
      unquote(block)
    end
  end

  def __field__(mod, num, name, type, opts) do
    fields = mod |> Module.get_attribute(@accumulating_fields_attr)

    if Keyword.has_key?(fields, name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    Module.put_attribute(mod, @accumulating_fields_attr, {name, build_field(num, name, type, opts)})
  end

  defmacro __compile_types_callbacks__(%Macro.Env{module: mod}) do
    extfit_types = mod |> Module.get_attribute(:extfit_types)

    types =
      extfit_types
      |> Enum.map(fn type ->
        {type.name, type}
      end)
      |> Enum.into(%{})

    Enum.each(unquote(@accumulating_types_attrs), &Module.delete_attribute(mod, &1))
    Module.put_attribute(mod, :types, types)

    quote do
      def types, do: @types

      @moduledoc """
      FIT Types for profile from version: #{@version}

      | Name | Base type |
      | ------ | ---- |
      #{Enum.map(@types, fn {name, type} -> "| #{name} | #{type.base_type.name} |" end) |> Enum.sort() |> Enum.join("\n")}
      """

      @doc """
      Get type by name
      """
      @spec by_name(atom) :: %ExtFit.Types.FieldType{} | {:error, {:type_not_found, atom}}
      def by_name(name) when is_atom(name), do: Map.get(@types, name) || {:error, {:type_not_found, name}}
    end
  end

  defmacro __compile_messages_callbacks__(%Macro.Env{module: mod}) do
    extfit_messages = mod |> Module.get_attribute(:extfit_messages) || []

    messages =
      extfit_messages
      |> Enum.map(fn {name, mod} -> {name, struct(mod)} end)
      |> Enum.into(%{})

    messages_num_mapping = Enum.map(messages, fn {_, msg} -> {msg.num, msg.name} end) |> Enum.into(%{})

    Enum.each(unquote(@accumulating_messages_attrs), &Module.delete_attribute(mod, &1))
    Module.put_attribute(mod, :messages, messages)
    Module.put_attribute(mod, :messages_num_mapping, messages_num_mapping)

    quote do
      @doc """
      Returns all known messages
      """
      def messages, do: @messages

      @doc """
      Get message by name
      """
      def by_name(name) when is_atom(name) do
        Map.get(@messages, name) || {:error, {:message_not_found, name}}
      end

      @doc """
      Get message by its number
      """
      def by_num(num) when is_number(num) do
        Map.get(@messages, Map.get(@messages_num_mapping, num)) || {:error, {:message_not_found, num}}
      end

      @timestamp_field %ExtFit.Types.Field{
        name: :timestamp,
        type: ExtFit.Types.by_name(:date_time),
        num: 253,
        units: "s"
      }

      @doc """
      Get field num for specific message.
      """
      @spec field_num(:message_index | :timestamp) :: integer
      def field_num(:message_index), do: 254
      def field_num(:timestamp), do: @timestamp_field.num

      @doc """
      Get field. Supports only :timestamp field for now which is shared between all messages.
      """
      @spec field(:timestamp) :: ExtFit.Types.Field.t()
      def field(:timestamp), do: @timestamp_field
    end
  end

  defmacro __compile_message_mod_callbacks__(%Macro.Env{module: mod}) do
    fields = mod |> Module.get_attribute(:extfit_acc_fields) || []

    fields =
      fields
      |> Enum.map(&elem(&1, 1))
      |> load_pending_values()
      |> Enum.map(&{&1.name, &1})
      |> Enum.into(%{})

    Module.delete_attribute(mod, @accumulating_fields_attr)
    Module.put_attribute(mod, :fields, fields)

    quote do
      @type t() :: %__MODULE__{
              num: integer,
              name: atom,
              fields: %{non_neg_integer() => ExtFit.Types.Field.t()}
            }
      defstruct num: @num, name: @name, fields: @fields

      @fields_table_doc @fields
                    |> Enum.sort_by(fn {_, %{num: num}} -> num end)
                    |> Enum.map(fn {name, field} ->
                      [
                        "| " <> to_string(name),
                        field.type.name,
                        field.num,
                        field.scale,
                        field.offset,
                        field.units,
                        to_string(field.array) <> " |"
                      ]
                      |> Enum.map(&(&1 || ""))
                      |> Enum.join(" | ")
                    end)
                    |> Enum.join("\n")
      @moduledoc """

      Message: `:#{@name}` identified by num=#{@num}

      ## Fields

      | Name  | Type | Num | Scale | Offset | Units | Array |
      |------ | ---- |---- | ----- | ------ | ----- | ----- |
      #{@fields_table_doc}
      """
    end
  end

  defp build_field(num, name, type, opts) do
    opts = Keyword.drop(opts, [:comment, :example])
    {subfields, opts} = Keyword.pop(opts, :subfields, [])
    {components, opts} = Keyword.pop(opts, :components, [])
    {units, opts} = Keyword.pop(opts, :units, [])
    units = units |> List.wrap()
    {scale, opts} = Keyword.pop(opts, :scale, [])
    scale = scale |> List.wrap()
    {offset, opts} = Keyword.pop(opts, :offset, [])
    offset = offset |> List.wrap()
    {bits, opts} = Keyword.pop(opts, :bits, [])
    {array, opts} = Keyword.pop(opts, :array, false)
    {accumulate, opts} = Keyword.pop(opts, :accumulate, [])
    type_struct = Types.by_name(type)

    if opts != [] do
      raise ArgumentError, "unknown option(s) #{inspect(opts)}"
    end

    if !type_struct do
      raise ArgumentError, "the type #{inspect(type)} is unknown"
    end

    subfields =
      Enum.map(subfields, fn opts ->
        opts = Map.drop(opts, [:comment, :example])
        {type, opts} = Map.pop(opts, :type, [])
        {name, opts} = Map.pop(opts, :name, [])
        type_struct = Types.by_name(type)
        {components, opts} = Map.pop(opts, :components, [])
        {accumulate, opts} = Map.pop(opts, :accumulate, [])
        accumulate = accumulate |> List.wrap()
        {ref_fields, opts} = Map.pop(opts, :ref_fields, [])
        {units, opts} = Map.pop(opts, :units, [])
        units = units |> List.wrap()
        {scale, opts} = Map.pop(opts, :scale, [])
        scale = scale |> List.wrap()
        {offset, opts} = Map.pop(opts, :offset, [])
        {bits, opts} = Map.pop(opts, :bits, [])

        if !type_struct do
          raise ArgumentError, "the type #{inspect(type)} is unknown"
        end

        if opts != %{} do
          raise ArgumentError, "unknown option(s) #{inspect(opts)}"
        end

        ref_fields =
          Enum.map(ref_fields, fn {name, value} ->
            {:pending,
             %Types.ReferenceField{
               name: name,
               value: value,
               raw_value: nil,
               num: nil
             }}
          end)

        %Types.Subfield{
          name: name,
          type: type_struct,
          num: num,
          components: components,
          ref_fields: ref_fields
        }
        |> set_field_components({scale, offset, units, bits, accumulate}, components)
      end)

    %Types.Field{
      num: num,
      type: type_struct,
      name: name,
      array: array,
      subfields: subfields
    }
    |> set_field_components({scale, offset, units, bits, accumulate}, components)
  end

  defp set_field_components(field, {scale, offset, units, bits, accumulate}, components) do
    components =
      components
      |> Enum.with_index()
      |> Enum.map(fn {name, index} when is_atom(name) ->
        {:pending,
         %Types.ComponentField{
           name: name,
           scale: Enum.at(scale, index),
           offset: Enum.at(offset, index),
           units: Enum.at(units, index),
           bits: Enum.at(bits, index),
           is_accumulated: Enum.at(accumulate, index),
           bit_offset:
             bits
             |> Enum.with_index()
             |> Enum.take_while(&(elem(&1, 1) < index))
             |> Enum.map(&elem(&1, 0))
             |> Enum.sum()
         }}
      end)

    if length(components) > 1 do
      %{field | scale: nil, offset: nil, units: nil, components: components}
    else
      %{
        field
        | scale: Enum.at(scale, 0),
          offset: Enum.at(offset, 0),
          units: Enum.at(units, 0),
          components: components
      }
    end
  end

  defp load_pending_values(fields) do
    fields
    |> Enum.map(&load_pending_field_values(&1, fields))
  end

  defp load_pending_field_values(
         %{components: components, ref_fields: ref_fields} = field,
         fields
       ) do
    %{
      field
      | components: load_pending_components(components, fields),
        ref_fields: load_pending_ref_fields(ref_fields, fields)
    }
  end

  defp load_pending_field_values(%{subfields: subfields, components: components} = field, fields) do
    %{
      field
      | components: load_pending_components(components, fields),
        subfields: load_pending_subfields(subfields, fields)
    }
  end

  defp load_pending_components(components, fields) do
    Enum.map(components, fn {:pending, component} ->
      %{num: num} = Enum.find(fields, {:error, {:not_found, components}}, &(&1.name == component.name))
      %{component | num: num}
    end)
  end

  defp load_pending_subfields(subfields, fields) do
    Enum.map(subfields, fn subfield ->
      load_pending_field_values(subfield, fields)
    end)
  end

  defp load_pending_ref_fields(ref_fields, fields) do
    Enum.map(ref_fields, fn {:pending, %Types.ReferenceField{} = ref_field} ->
      %{num: num, type: %Types.FieldType{} = type} =
        Enum.find(fields, {:error, {:not_found, ref_field}}, &(&1.name == ref_field.name))

      {_, %{num: raw_value}} = Enum.find(type.values, &(elem(&1, 1).name == ref_field.value))

      %{ref_field | raw_value: raw_value, num: num}
    end)
  end
end

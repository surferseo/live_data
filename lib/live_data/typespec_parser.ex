defmodule LiveData.TypespecParser do
  def to_ts(spec) do
    """
    export type State = #{state(spec)}

    export type Actions = {
    #{
      actions(spec)
      |> Enum.map(fn {action, params} -> "  #{action}: #{to_type(params)}" end)
      |> Enum.join("\n")
    }
    }

    export type ActionName = keyof Actions

    export type Action = <T extends ActionName>(
      action: T,
      params: Actions[T]
    ) => Promise<null>
    """
  end

  def state([]), do: []

  def state(specs) do
    specs
    |> Enum.filter(fn
      {:spec, {_, _, [{:serialize, _, _}, _]}, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {:spec, {_, _, [{:serialize, _, _}, type]}, _} ->
      to_type(type)
    end)
    |> Enum.join("|")
  end

  def actions([]) do
    []
  end

  def actions(specs) do
    specs
    |> Enum.filter(fn
      {:spec, {_, _, [{:handle_call, _, _}, _]}, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {:spec, {_, _, [{:handle_call, _, [{action_name, params}, _, _]}, _]}, _} ->
      {action_name, to_type(params)}
    end)
  end

  def to_type({:list, _, [type]}) do
    IO.inspect(type)

    "#{to_type(type)}[]"
  end

  def to_type({:%{}, _, map_fields}) do
    "{\n#{map_fields |> Enum.map(fn t -> "  #{to_type(t)}" end) |> Enum.join("\n")}\n}"
  end

  def to_type({key, value_type}) do
    "#{key}: #{to_type(value_type)}"
  end

  def to_type({:|, _, types}) do
    types |> Enum.map(&to_type/1) |> Enum.join("|")
  end

  def to_type(nil) do
    "null"
  end

  def to_type({:boolean, _, []}) do
    "boolean"
  end

  def to_type({:integer, _, []}) do
    "number"
  end

  def to_type({:map, _, []}) do
    "Object"
  end

  def to_type({{:., _, [{_, _, [:String]}, _]}, _, _}) do
    "string"
  end

  def to_type(type), do: type
end

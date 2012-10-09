defmodule Exn do

  defexception DecodeError, message: nil

  def decode(string) when is_binary(string) do
    ast_to_value(Code.string_to_ast!(string))
  end

  defp ast_to_value({:-, _, [number]}) when is_number(number) do
    -number
  end
  defp ast_to_value({:+, _, [number]}) when is_number(number) do
    number
  end
  defp ast_to_value({:access, line, [record, fields]}) do
    record = ast_to_value(record)
    fields = ast_to_value(fields)
    {r, _} = Code.eval_quoted({:access, line, [record, fields]})
    r
  end
  defp ast_to_value({:<<>>, line, items}) do
   {b, _} = Code.eval_quoted({:<<>>, line, 
   lc item inlist items do
     case item do
       {:"::", line, [v|t]} -> {:"::", line, [ast_to_value(v)|t]}
       _ -> ast_to_value(item)
     end
   end})
   b
  end
  defp ast_to_value({:__block__,_, [item]}), do: ast_to_value(item)
  defp ast_to_value({:__block__,_, items}), do: ast_to_value(items)
  defp ast_to_value({a,b}), do: {ast_to_value(a), ast_to_value(b)}
  defp ast_to_value({:{}, _, items}), do: list_to_tuple(ast_to_value(items))
  defp ast_to_value(items) when is_list(items) do
    lc item inlist items, do: ast_to_value(item)    
  end
  defp ast_to_value(item) do
   if Macro.term?(item) do
     item
   else
    raise DecodeError, message: "#{Macro.to_binary(item)} is invalid"
   end
  end


  def encode(terms) when is_list(terms) do
    if keywords?(terms) do
      "[" <> 
      Enum.join(
      lc {key, value} inlist terms do
        "#{key}: " <> encode(value)
      end, ", ")
       <> "]"
    else
      inspect terms
    end
  end
  def encode(term), do: inspect(term)

  defp keywords?(terms) do
    Enum.all?(terms,
              function do
               {key, _value} ->
                is_atom(key)
               _ ->
                false
              end) and
    List.sort(terms) == terms
  end
end
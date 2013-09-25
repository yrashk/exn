defexception Exn.DecodeError, message: nil

defmodule Exn.Decoder do

  alias Exn.DecodeError, as: DecodeError

  def decode(string, options) when is_binary(string) do
    ast_to_value(Code.string_to_quoted!(string, options))
  end

  defp ast_to_value({:-, _, [number]}) when is_number(number) do
    -number
  end
  defp ast_to_value({:+, _, [number]}) when is_number(number) do
    number
  end
  defp ast_to_value({:__r__, _, [val, opts]}) do
    Regex.compile!(ast_to_value(val), ast_to_value(opts))
  end
  defp ast_to_value({:__aliases__, _, aliases}) do
    aliases = ast_to_value(aliases)
    Module.concat aliases
  end
  defp ast_to_value({:.., _, values}) do
    values = ast_to_value(values)
    [first, last] = values
    first..last
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
       {:::, line, [v|t]} -> {:::, line, [ast_to_value(v)|t]}
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
   case Macro.safe_term(item) do
     :ok -> item
     {:unsafe, term} ->
       raise DecodeError, message: "#{Macro.to_binary(term)} is invalid"
   end
  end

end

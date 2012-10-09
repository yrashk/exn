defmodule Exn do
  def decode(string) when is_binary(string) do
    values =
    case Code.string_to_ast!(string) do
      {:__block__,_, [item]} -> item
      {:__block__,_, items} -> items
      item -> item
    end
    unless Macro.term?(values) do
      {:error, :term_expected}
    else 
      values
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
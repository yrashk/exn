defprotocol Exn.Encoder do
  def encode(term)
end

defimpl Exn.Encoder, for: Tuple do
  def encode(term) when tuple_size(term) > 1 and is_atom(elem(term, 0)) do
    m = elem(term, 0)
    Code.ensure_loaded(m)
    if function_exported?(m, :__record__, 1) do
      "{#{Enum.join(Module.split(m),".")},#{Exn.Encoder.encode(m.to_keywords(term))}}"
    else
      inspect(term)
    end
  end
  def encode(term) do    
    inspect(term)
  end
end

defimpl Exn.Encoder, for: Atom do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: List do
  def encode(terms) do
    if keywords?(terms) do
      "[" <> 
      Enum.join(
      lc {key, value} inlist terms do
        "#{key}: " <> Exn.Encoder.encode(value)
      end, ", ")
       <> "]"
    else
      inspect terms
    end  
  end

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

defimpl Exn.Encoder, for: BitString do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Number do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Function do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: PID do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Port do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Reference do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

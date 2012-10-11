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
      inspect(term, raw: true)
    end
  end
  def encode(term) do    
    inspect(term, raw: true)
  end
end

defimpl Exn.Encoder, for: Any do
  def encode(term), do: inspect(term, raw: true)
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

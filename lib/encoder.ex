defexception Exn.EncodeError, value: nil do
  def message(term) when is_reference(term), do: "References can't be encoded"
  def message(term), do: "#{inspect term} can't be encoded"
end

defprotocol Exn.Encoder do
  def encode(term)
end

defimpl Exn.Encoder, for: Regex do
  def encode(term), do: inspect(term)
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

defimpl Exn.Encoder, for: PID do
  def encode(term), do: "%p#{inspect(term, raw: true)}"
end

defimpl Exn.Encoder, for: Reference do
  def encode(term), do: raise Exn.EncodeError, value: term
end

defimpl Exn.Encoder, for: Atom do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: List do
  def encode(term), do: inspect(term)
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

defimpl Exn.Encoder, for: Any do
  def encode(term), do: inspect(term, raw: true)
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

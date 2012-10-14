defexception Exn.EncodeError, value: nil do
  def message(exception), do: "#{inspect exception.value} cannot be encoded"
end

defprotocol Exn.Encoder do
  def encode(term)
end

lc target inlist [Atom, List, Number, BitString, Regex] do
  defimpl Exn.Encoder, for: target do
    def encode(term), do: inspect(term)
  end
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

defimpl Exn.Encoder, for: Tuple do
  def encode(term) when tuple_size(term) > 1 and is_atom(elem(term, 0)) do
    m = elem(term, 0)
    if function_exported?(m, :__record__, 1) do
      raise Exn.EncodeError, value: term
    else
      inspect(term, raw: true)
    end
  end
  def encode(term) do
    inspect(term, raw: true)
  end
end

lc target inlist [PID, Function, Reference, Port] do
  defimpl Exn.Encoder, for: target do
    def encode(term), do: raise Exn.EncodeError, value: term
  end
end
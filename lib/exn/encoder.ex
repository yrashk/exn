defexception Exn.EncodeError, value: nil do
  def message(exception), do: "#{inspect exception.value} cannot be encoded"
end

defprotocol Exn.Encoder do
  def encode(term)
end

defimpl Exn.Encoder, for: [Atom, List, Number, BitString, Regex] do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

defimpl Exn.Encoder, for: Tuple do
  def encode(term) when tuple_size(term) > 1 and is_atom(elem(term, 0)) do
    inspect(term, raw: true)
  end
  def encode(term) do
    inspect(term, raw: true)
  end
end

defimpl Exn.Encoder, for: [PID, Function, Reference, Port] do
  def encode(term), do: raise Exn.EncodeError, value: term
end

defprotocol Exn.Encoder do
  def encode(term)
end

defimpl Exn.Encoder, for: Tuple do
  def encode(term), do: inspect(term)
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

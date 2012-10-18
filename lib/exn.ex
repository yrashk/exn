defmodule Exn do

  def encode(term), do: Exn.Encoder.encode(term)
  def decode(term, options // []), do: Exn.Decoder.decode(term, options)

end

defmodule Exn do

  def encode(term), do: Exn.Encoder.encode(term)

  def decode(term), do: Exn.Decoder.decode(term)

end

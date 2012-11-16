Code.require_file "../test_helper.exs", __FILE__

defmodule ExnTest.Properties do
  use Proper.Properties

  property "encoded data, decoded back is the same data" do
    forall x in oneof([binary, bitstring, list, tuple, atom, float, integer]), do: Exn.decode(Exn.encode(x)) == x
  end
end

defrecord TestRecord, a: nil

defmodule ExnTest do
  use ExUnit.Case
  use Proper.Properties

  test "module" do
    assert Proper.module(ExnTest.Properties, numtests: 1000) == []
  end

  test "keyword encoding" do
    assert Exn.encode([a: 1, b: 2]) == "[a: 1, b: 2]"
    assert Exn.encode([{:b, 1}, {:a, 2}]) == "[b: 1, a: 2]"
  end

  test "keyword decoding" do
    assert Exn.decode("[a: 1, b: 2]") == [a: 1, b: 2]
    assert Exn.decode("[{:b,1},{:a,2}]") == [b: 1, a: 2]
  end

  test "range encoding" do
    assert Exn.encode(1..2) == "1..2"
    assert Exn.encode(-9..-1) == "-9..-1"
  end

  test "range decoding" do
    assert Exn.decode("1..2") == 1..2
    assert Exn.decode("-9..-1") == -9..-1
  end

  test "regexp encoding" do
    assert Exn.encode(%r(.*)) == "%r\".*\""
  end

  test "regexp decoding" do
    assert Exn.decode("%r\".*\"") == %r(.*)
  end

  test "record encoding" do
    assert Exn.encode(TestRecord.new(a: 1)) == "{TestRecord,[a: 1]}"
  end

  test "record decoding" do
    assert Exn.decode("{TestRecord,[a: 1]}") == {TestRecord,[a: 1]}
  end

  test "pid encoding" do
    me = self
    assert Exn.EncodeError[value: ^me] = catch_error(Exn.encode(me))
  end

  test "function encoding" do
    f = fn() -> end
    assert Exn.EncodeError[value: ^f] = catch_error(Exn.encode(f))
  end

  test "reference encoding" do
    r = make_ref
    assert Exn.EncodeError[value: ^r] = catch_error(Exn.encode(r))
  end

  test "port encoding" do
    p = hd(Port.list)
    assert Exn.EncodeError[value: ^p] = catch_error(Exn.encode(p))
  end

  test "default record encoding" do
    record = File.Stat.new
    assert Exn.decode(Exn.encode(record)) == record
  end

  test "overridden record encoding" do
    record = File.Stat.new
    {:module, module, _, _} =
    defimpl Exn.Encoder, for: File.Stat do
      def encode(_), do: "custom"
    end
    assert Exn.encode(record) == "custom"
    :code.delete module
    :code.purge module
  end

end

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
    assert Exn.encode([{:b, 1}, {:a, 2}]) == "[{:b,1},{:a,2}]"
  end

  test "range encoding" do
    assert Exn.encode(1..2) == "1..2"
    assert Exn.decode("1..2") == 1..2
    assert Exn.encode(-9..-1) == "-9..-1"
    assert Exn.decode("-9..-1") == -9..-1
  end

  test "regexp encoding" do
    assert Exn.encode(%r(.*)) == "%r\".*\""
    assert Exn.decode("%r\".*\"") == %r(.*)
  end

  test "record encoding" do
    r = TestRecord.new(a: 1)
    assert Exn.EncodeError[value: r] = catch_error(Exn.encode(r))
  end

  test "pid encoding" do
    self_s = list_to_binary(pid_to_list(self))
    assert Exn.encode(self) == "%p#{self_s}"
    assert Exn.decode(Exn.encode(self)) == self
  end

  test "function encoding" do
    f = fn() -> end
    assert Exn.EncodeError[value: r] = catch_error(Exn.encode(f))
  end

  test "reference encoding" do
    r = make_ref
    assert Exn.EncodeError[value: r] = catch_error(Exn.encode(r))
  end

  test "port encoding" do
    p = Port.open { :spawn, :echo }, [:hide]
    assert Exn.EncodeError[value: r] = catch_error(Exn.encode(p))
  end
end

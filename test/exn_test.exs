Code.require_file "../test_helper.exs", __FILE__

defmodule ExnTest.Properties do
  use Proper.Properties

  property "encoded data, decoded back is the same data" do
    forall x in term, do: Exn.decode(Exn.encode(x)) == x
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
  end

  test "record encoding" do
    assert Exn.encode(TestRecord.new(a: 1)) == "{TestRecord,[a: 1]}"
    assert Exn.decode("{TestRecord,[a: 1]}") == {TestRecord,[a: 1]}
  end
end

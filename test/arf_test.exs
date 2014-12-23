defmodule ARFTest do
  use ExUnit.Case
  require Record

  test "new is not nil valid record" do
    arf = ARF.new()
    assert Record.is_record(arf)
    assert arf != nil
  end

  test "membership for nil" do
    assert ARF.member(nil, 1) == false
  end

  test "simple one insert and membership" do
    arf = ARF.new()
    arf = ARF.insert(arf, 1)
    assert ARF.member(arf, 1)
  end

  test "simple two inserts and membership" do
    arf = ARF.new()
    arf = ARF.insert(arf, 1)
    arf = ARF.insert(arf, 2)
    assert ARF.member(arf, 2)
    assert ARF.member(arf, 1)
  end
end

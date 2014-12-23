defmodule ArfTest do
  use ExUnit.Case#, async: true
  require Record

  test "new is not nil valid record" do
    arf = Arf.new()
    assert Record.is_record(arf)
    assert arf != nil
  end

  test "membership for nil" do
    assert Arf.member(nil, 1) == false
  end

  test "simple one insert and membership" do
    arf = Arf.new()
    arf = Arf.insert(arf, 1, 2)
    assert Arf.member(arf, 1)
  end

  test "duplicate insert and membership" do
    arf = Arf.new()
    arf = Arf.insert(arf, 1, 2)
    arfsecond = Arf.insert(arf, 1, 2)
    assert arf == arfsecond
  end

 test "insert two with a superset " do
   arf = Arf.new()
   arf = Arf.insert(arf, 3, 6)
   arf = Arf.insert(arf, 2, 8)
   assert Arf.member(arf, 2)
   assert Arf.member(arf, 3)
   assert Arf.member(arf, 6)
   assert Arf.member(arf, 8)
   assert Arf.member(arf, 5)
  end

 test "insert two with a subset " do
   arf = Arf.new()
   arf = Arf.insert(arf, 2, 8)
   arf = Arf.insert(arf, 3, 6)
   assert Arf.member(arf, 2)
   assert Arf.member(arf, 3)
   assert Arf.member(arf, 6)
   assert Arf.member(arf, 8)
   assert Arf.member(arf, 5)
  end

  test "two inserts non-overlapping" do
   arf = Arf.new()
   arf = Arf.insert(arf, 1, 2)
   arf = Arf.insert(arf, 3, 4)
   assert Arf.member(arf, 2)
   assert Arf.member(arf, 3)
  end

  test "two inserts non-overlapping reverse order" do
   arf = Arf.new()
   arf = Arf.insert(arf, 3, 4)
   arf = Arf.insert(arf, 1, 2)
   assert Arf.member(arf, 2)
   assert Arf.member(arf, 3)
  end

  test "two inserts overlapping with existing beginning of ranger" do
   arf = Arf.new()
   arf = Arf.insert(arf, 3, 10)
   arf = Arf.insert(arf, 1, 7)
   assert Arf.member(arf, 1)
   assert Arf.member(arf, 10)
   assert Arf.member(arf, 3)
   assert Arf.member(arf, 7)
   assert Arf.member(arf, 5)
  end

  test "two inserts overlapping with existing end of ranger" do
   arf = Arf.new()
   arf = Arf.insert(arf, 3, 10)
   arf = Arf.insert(arf, 8, 20)
   assert Arf.member(arf, 3)
   assert Arf.member(arf, 10)
   assert Arf.member(arf, 8)
   assert Arf.member(arf, 20)
   assert Arf.member(arf, 9)
  end

  test "three inserts non-overlapping" do
    arf = Arf.new()
          |> Arf.insert(1, 2)
          |> Arf.insert(3, 4)
          |> Arf.insert(5, 6)

    assert Arf.member(arf, 1)
    assert Arf.member(arf, 3)
    assert Arf.member(arf, 6)

    assert Arf.member(arf, -1) == false
    assert Arf.member(arf, 8) == false
  end

  test "three inserts non-overlapping reverse" do
    arf = Arf.new()
          |> Arf.insert(5, 6)
          |> Arf.insert(3, 4)
          |> Arf.insert(1, 2)

    assert Arf.member(arf, 1)
    assert Arf.member(arf, 3)
    assert Arf.member(arf, 6)

    assert Arf.member(arf, -1) == false
    assert Arf.member(arf, 8) == false
  end
end

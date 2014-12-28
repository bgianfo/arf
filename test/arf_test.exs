defmodule ArfTest do

  use ExUnit.Case, async: true

  doctest Arf

  require Record

  """
  Macro for bulk asserting membership.
  """
  defmacrop assert_members(arf, list) do
    for val <- list do
      quote do
        assert Arf.contains(unquote(arf), unquote(val))
      end
    end
  end

  """
  Macro for bulk asserting non-membership.
  """
  defmacrop refute_members(arf, list) do
    for val <- list do
      quote do
        refute Arf.contains(unquote(arf), unquote(val))
      end
    end
  end

  test "new is not nil valid record" do
    arf = Arf.new()
    assert Record.is_record(arf)
    assert arf != nil
  end

  test "membership for nil" do
    refute Arf.contains(nil, 1)
  end

  test "Insert invalid range throws" do
    assert_raise(RuntimeError, fn ->
      Arf.new() |> Arf.put(6,3)
    end)
  end

  test "simple one insert and membership" do
    arf = Arf.new()
    arf = Arf.put(arf, 1, 2)
    assert Arf.contains(arf, 1)
  end

  test "simple one insert and membership with false" do
    arf = Arf.new()
    arf = Arf.put(arf, 1, 2, false)
    refute Arf.contains(arf, 1)
  end

  test "duplicate insert and membership" do
    arf = Arf.new() |> Arf.put(1, 2)
    arfsecond = Arf.put(arf, 1, 2)
    assert arf == arfsecond
  end

  test "simple one insert and overwrite with false" do
    arf = Arf.new()
          |> Arf.put(1, 2, true)
          |> Arf.put(1, 2, false)

    refute Arf.contains(arf, 1)
  end

  test "insert two with a superset " do
    arf = barf([{3, 6}, {2, 8}])
    assert_members(arf, [2, 3, 6, 8, 5])
  end

  test "insert two with a subset " do
    arf = barf([{2, 8}, {3, 6}])
    assert_members(arf, [2, 3, 6, 8, 5])
  end

  test "two inserts non-overlapping" do
    arf = barf([{1,2}, {3,4}])
    assert_members(arf, [2, 3])
  end

  test "two inserts non-overlapping reverse order" do
    arf = barf([{3,4}, {1,2}])
    assert_members arf, [2, 3]
  end

  test "two inserts overlapping with existing beginning of ranger" do
    arf = barf([{3,10}, {1,7}])
    assert_members arf, [1, 10, 3, 7, 5]
  end

  test "two inserts overlapping with existing end of ranger" do
    arf = barf([{3,8}, {8,20}])
    assert_members arf, [3, 10, 8, 20, 9]
  end

  test "three inserts non-overlapping" do
    arf = barf([{1,2}, {3,4}, {5,6}])
    assert_members arf, [1, 3, 6]
    refute_members arf, [-1, 8]
  end

  test "three inserts non-overlapping reverse" do
    arf = barf([{5,6}, {3,4}, {1,2}])
    assert_members arf, [1, 3, 6]
    refute_members arf, [-1, 8]
  end

  test "three inserts overlapping" do
    arf = barf([{1,3}, {2,4}, {3,6}])
    assert_members arf, [1, 3, 6]
    refute_members arf, [-1, 8]
  end

  test "three inserts overlapping - different order" do
    arf = barf([{1,3}, {4,6}, {2, 5}])
    assert_members arf, [1, 3, 6]
    refute_members arf, [-1, 8]
  end

  test "six inserts non-overlapping" do

    arf = barf([{5,6}, {3,4}, {1,2}, {7,8}, {-2, -1}, {9, 10}])

    # Validate positive memberships
    assert_members arf, [1,3,6,-1,8,10]

    # Validate negative memberships
    refute_members arf, [-8, 0]

    ex = {Arf, nil, {-2, 10},
           {Arf, nil, {-2, 4},
             {Arf, nil, {-2, 2},
               {Arf, true, {-2, -1}, nil, nil},
               {Arf, true, {1, 2}, nil, nil}},
             {Arf, true, {3, 4}, nil, nil}},
           {Arf, nil, {5, 10},
             {Arf, true, {5, 6}, nil, nil},
             {Arf, nil, {7, 10},
               {Arf, true, {7, 8}, nil, nil},
               {Arf, true, {9, 10}, nil, nil}}}}

    assert arf == ex
  end

  test "large range inserts" do

    arf = barf([{-20,5}, {3,100}, {75,100}, {500,1000}, {2000, 9000}])

    #assert_members arf, [-20, 3, 4, 5, 74, 75, 1000, 2000, 9000]

    assert arf == {Arf, nil, {-20, 9000},
                    {Arf, true, {-20, 40}, nil, nil},
                    {Arf, nil, {41, 9000},
                      {Arf, true, {41, 100}, nil, nil},
                      {Arf, nil, {500, 9000},
                        {Arf, true, {500, 1000}, nil, nil},
                        {Arf, true, {2000, 9000}, nil, nil}}}}
  end

  """
  Build an arf from a list of ranges
  """
  defp barf(ranges) do

    Enum.reduce(ranges, Arf.new(), fn {s, e}, acc ->
      Arf.put(acc, s, e)
    end)

  end

end

defmodule Arf do
  @moduledoc """
  This module defines a data structure known as an
  Adaptive Range Filter. The data structure tracks
  ranges of data and lets the user probe it for
  membership information with a certain degree of
  confidence.
  """

  require Record
  require Statistics

  @type tree_type :: {atom, boolean, {number|nil, number|nil}, nil | tree_type, nil | tree_type}

  Record.defrecordp :tree, __MODULE__, occupied: nil, range: {nil,nil}, left: nil, right: nil

  @doc """
  Returns a new (empty) Adaptive Range Filter.

  ## Examples

      iex> arf = Arf.new()
      {Arf, nil, {nil, nil}, nil, nil}

  """
  @spec new() :: tree_type
  def new(), do: tree()

  @doc """
  Encode a range of data staring at `ins_begin` to `ins_end` into the Adaptive Range Filter `tree`.
  Returns the modified Adaptive Range Filter `tree`.

  ## Examples

      iex> Arf.new() |> Arf.put(1, 300)
      {Arf, true, {1, 300}, nil, nil}

  """
  @spec put(tree_type, number, number, boolean) :: tree_type

  def put(tree, ins_begin, ins_end, exists \\ true) when Record.is_record(tree) do
    {__MODULE__, occupied, range, left_node, right_node} = tree

    iput({occupied, range, left_node, right_node}, ins_begin, ins_end, exists)
  end
 
  # Handle error case for invalid paramaters.
  defp iput({_, {_, _}, _, _}, i_begin, i_end, _) when i_begin > i_end do
    raise "The start of the range being inserted (#{i_begin}) is greater than the end of the range (#{i_end})."
  end

  # Handle insertion to root.
  defp iput({nil, {_, _}, nil, nil}, i_begin, i_end, exists) do
    tree(occupied: exists, range: {i_begin, i_end})
  end

  # Handle insertion of subset in root.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, exists)
  when i_begin >= r_begin and i_end <= r_end do
    # Need to create a new tree, since we don't have access to the original
    tree(occupied: exists, range: {r_begin, r_end})
  end

  # Handle insertion of superset in root.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, _exists)
  when i_begin <= r_begin and i_end >= r_end do
    tree(occupied: true, range: {i_begin, i_end})
  end

  # Handle split of root where the inserted range is greater than existing.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, _exists)
  when i_begin > r_end do
    tree(range: {r_begin, i_end},
      left: tree(occupied: true, range: {r_begin, r_end}),
      right: tree(occupied: true, range: {i_begin, i_end}))
  end

  # Handle split of root where the inserted range is less than existing.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, _exists)
  when i_end < r_begin do
    tree(range: {i_begin, r_end},
      left: tree(occupied: true, range: {i_begin, i_end}),
      right: tree(occupied: true, range: {r_begin, r_end}))
  end

  # Handle split of root where the inserted range intersect with beginning of existing.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, _exists)
  when i_end in r_begin .. r_end do
    mid = Statistics.median(i_begin .. r_end)

    tree(range: {i_begin, r_end},
      left: tree(occupied: true, range: {i_begin, mid}),
      right: tree(occupied: true, range: {mid+1, r_end}))
  end

  # Handle split of root where the inserted range intersect with end of existing.
  defp iput({true, {r_begin, r_end}, nil, nil}, i_begin, i_end, _exists)
  when r_end in i_begin .. i_end do
    mid = Statistics.median(r_begin .. i_end)

    tree(range: {r_begin, i_end},
      left: tree(occupied: true, range: {r_begin, mid}),
      right: tree(occupied: true, range: {mid+1, i_end}))
  end

  # Node with real data on both sides.
  defp iput({nil, {r_begin, r_end}, ln, rn}, i_begin, i_end, exists) do
    {_, _, {_, lre}, _, _} = ln

    # If the range can fit left, go there, otherwise go right
    #
    if (i_end <= lre) do
     {__MODULE__, ln_occ, ln_range, ln_ln, ln_rn} = ln
     newnode = iput({ln_occ, ln_range, ln_ln, ln_rn}, i_begin, i_end, exists)

     tree(range: {min(r_begin, i_begin), r_end},
         left: newnode,
         right: rn)
    else
     {__MODULE__, rn_occ, rn_range, rn_ln, rn_rn} = rn
     newnode = iput({rn_occ, rn_range, rn_ln, rn_rn}, i_begin, i_end, exists)

     tree(range: {r_begin, max(r_end, i_end)},
         left: ln,
         right: newnode)
    end
  end

  @doc """
  Check if a `value` is encoded in the Adaptive Range Filter `tree`.
  Returns `true` if so, `false` otherwise

  ## Examples

      iex> Arf.new() |> Arf.put(1, 300) |> Arf.contains(5)
      true

      iex> Arf.new() |> Arf.put(1, 300) |> Arf.contains(750)
      false

  """
  @spec contains(tree_type, number) :: boolean
  def contains(nil, _value), do: false
  def contains(tree, value) when Record.is_record(tree) do

    {__MODULE__, occupied, {range_begin, range_end}, lnode, rnode} = tree

    case {occupied, lnode, rnode} do

      # Empty tree, when not occupied
      {nil, nil, nil} ->
        false

      # Occupied root or leaf node.
      {true, nil, nil} ->
        range_begin <= value and value <= range_end

      # Un-occupied root or leaf node.
      {false, nil, nil} ->
        false

      # Root with nodes..
      # If we are a root we can short circuit queries into the tree
      # when the value is out of the entire range of the tree.
      {nil, l, r} when range_begin <= value and value <= range_end ->
          contains(l, value) || contains(r, value)

      # Root with nodes out of range ..
      {nil, _, _} -> false

    end

  end

end

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

  def put(_tree, ins_begin, ins_end, _exists) when ins_begin > ins_end do
      raise "The start of the range being inserted (#{ins_begin}) is greater than the end of the range (#{ins_end})."
  end

  def put(tree, ins_begin, ins_end, exists \\ true) when Record.is_record(tree) do

    {__MODULE__, occupied, {range_begin, range_end}, left_node, right_node} = tree

    case {occupied, left_node, right_node} do

      # Empty tree, when not occupied
      {nil, nil, nil} ->
        tree(occupied: exists, range: {ins_begin, ins_end})

      # Handle insertion of subset in root.
      #
      {true, nil, nil} when ins_begin >= range_begin and ins_end <= range_end ->
        tree

      # Handle insertion of superset in root.
      #
      {true, nil, nil} when ins_begin <= range_begin and ins_end >= range_end ->
        tree(occupied: true, range: {ins_begin, ins_end})

      # Handle split of root where the inserted range is greater than existing.
      #
      {true, nil, nil} when ins_begin > range_end ->
        tree(range: {range_begin, ins_end},
             left: tree(occupied: true, range: {range_begin, range_end}),
             right: tree(occupied: true, range: {ins_begin, ins_end}))

      # Handle split of root where the inserted range is less than existing.
      #
      {true, nil, nil} when ins_end < range_begin ->
        tree(range: {ins_begin, range_end},
             left: tree(occupied: true, range: {ins_begin, ins_end}),
             right: tree(occupied: true, range: {range_begin, range_end}))

      # Handle split of root where the inserted range intersect with beginning of existing.
      #
      {true, nil, nil} when ins_end in range_begin .. range_end ->
        mid = Statistics.median(ins_begin .. range_end)

        tree(range: {ins_begin, range_end},
             left: tree(occupied: true, range: {ins_begin, mid}),
             right: tree(occupied: true, range: {mid+1, range_end}))

      # Handle split of root where the inserted range intersect with end of existing.
      #
      {true, nil, nil} when range_end in ins_begin .. ins_end ->
        mid = Statistics.median(range_begin .. ins_end)

        tree(range: {range_begin, ins_end},
             left: tree(occupied: true, range: {range_begin, mid}),
             right: tree(occupied: true, range: {mid+1, ins_end}))

      # Node with real data on both sides.
      #
      {nil, ln, rn} ->
        {_, _, {_, lre}, _, _} = ln

        # If the range can fit left, go there, otherwise go right
        #
        if (ins_end <= lre) do
         newnode = put(ln, ins_begin, ins_end)
         tree(range: {min(range_begin, ins_begin), range_end},
             left: newnode,
             right: rn)
        else
         newnode = put(rn, ins_begin, ins_end)
         tree(range: {range_begin, max(range_end, ins_end)},
             left: ln,
             right: newnode)
        end
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

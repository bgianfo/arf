defmodule Arf do

  require Record

  require Statistics

  # Invariant: left.range <= range <= right.range
  Record.defrecordp :tree, __MODULE__, occupied: nil, range: {nil,nil}, left: nil, right: nil

  @doc """
  Returns a new (empty) Adaptive Range Filter.
  """
  def new() do
    tree()
  end

  @doc """
  Encode a single value into the Adaptive Range Filter.
  Returns the modified Adaptive Range Filter.
  """
  def insert(tree, ins_begin, ins_end) when Record.is_record(tree) do

    if (ins_begin > ins_end) do
      raise "Inserted range begining must be less than inserted range end."
    end

    {__MODULE__, occupied, {range_begin, range_end}, left_node, right_node} = tree

    case {occupied, left_node, right_node} do

      # Empty tree, when not occupied
      {nil, nil, nil} ->
        tree(occupied: true, range: {ins_begin, ins_end})

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
         newnode = insert(ln, ins_begin, ins_end)
         tree(range: {min(range_begin, ins_end), range_end},
             left: newnode,
             right: rn)
        else
         newnode = insert(rn, ins_begin, ins_end)
         tree(range: {range_begin, max(range_end, ins_end)},
             left: ln,
             right: newnode)
        end
    end
  end

  @doc """
  Check if a value is encoded in the Adaptive Range Filter.
  Returns `true` if so, `false` otherwise
  """
  def member(nil, _value), do: false
  def member(tree, value) when Record.is_record(tree) do

    {__MODULE__, occupied, {range_begin, range_end}, left_node, right_node} = tree

    case {occupied, left_node, right_node} do

      # Empty tree, when not occupied
      {nil, nil, nil} ->
        false

      # Occupied root or leaf node.
      {true, nil, nil} ->
        range_begin <= value and value <= range_end

      # Un-Occupied root or leaf node.
      {false, nil, nil} ->
        false

      # Root with nodes
      {nil, l, r} ->
        member(l, value) || member(r, value)

    end

  end

end

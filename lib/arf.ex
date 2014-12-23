defmodule ARF do

  require Record

  # Invariant: left.range <= range <= right.range
  Record.defrecordp :tree, __MODULE__, occupied: false, range: {nil,nil}, left: nil, right: nil

  def new() do
    tree()
  end

  @doc """
  Encode a single value into the Adaptive Range Filter.
  Returns the modified Adaptive Range Filter.
  """
  def insert({_tag, occupied, _range, _left, _right}, value) do
    if (!occupied) do
      tree(range: {value, value}, occupied: true)
    else
      raise "Not Implemented!"
    end
  end

  @doc """
  Check if a value is encoded in the Adaptive Range Filter.
  Returns `true` if so, `false` otherwise
  """
  def member(nil, _value), do: false
  def member(tree, value) when Record.is_record(tree) do
    {__MODULE__, _occupied, range, left_node, right_node} = tree
    if (in_range(range, value)) do
      member_branch(left_node, value) || member_branch(right_node, value)
    else
      false
    end
  end

  """
  Performs the actual tree traversal.
  """
  defp member_branch({__MODULE__, occupied, range, _left, _right}, value) do
    if (occupied and in_range(range, value)) do
      true
    else
      false
    end
  end

  defp in_range({range_begin, range_end}, value) do
    range_begin <= value and range_end >= value
  end

  """
  Check if this is a leaf node in the tree.
  Returns `true` if so, `false` otherwise.
  """
  #defp is_leaf({_tag, _occupied, _range, _left, _right}), do:  true
  #defp is_leaf({_tag, _occupied, _range, nil, nil}), do: false


end

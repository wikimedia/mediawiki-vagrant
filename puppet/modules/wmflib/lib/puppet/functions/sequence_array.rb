# == Function: sequence_array( $start, $count )
#
# Returns an array of integers, whose first value is $start and
# with increment values, totalling $count items.
#
# === Examples
#
#  sequence_array(8889, 4)  # [8889, 8890, 8891, 8892]
#  sequence_array(80, 2)  # [80, 81]
#
Puppet::Functions.create_function(:sequence_array) do
  dispatch :sequence_array do
    param 'Any', :start
    param 'Any', :count
  end

  def sequence_array(start, count)
    start = start.to_i
    stop = start + count.to_i
    (start...stop).to_a
  end
end

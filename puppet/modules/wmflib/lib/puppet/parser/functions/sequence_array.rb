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
module Puppet::Parser::Functions
  newfunction(:sequence_array, :type => :rvalue, :arity => 2) do |args|
    start = args[0].to_i
    count = args[1].to_i
    stop = start + count
    range = start...stop
    range.to_a
  end
end

# == Function: to_seconds( string $time_spec )
#
# Convert a unit of time expressed as a string to seconds.
#
# === Examples
#
#  to_seconds('9000ms')  # 9
#  to_seconds('1hr')     # 3600
#  to_seconds('2 days')  # 172800
#
Puppet::Functions.create_function(:to_seconds) do
  dispatch :to_seconds do
    param 'String', :time_spec
  end

  def to_seconds(time_spec)
    s = call_function('to_milliseconds', time_spec) / 1000.0
    s.to_i == s ? s.to_i : s
  end
end

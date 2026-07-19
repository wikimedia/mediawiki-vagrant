# == Function: conflicts( string|resource $resource )
#
# Throw an error if a resource is declared.
#
# === Examples
#
#  # Resource name
#  conflicts('::redis::legacy')
#
#  # Resource
#  conflicts(Class['::redis-server'])
#
Puppet::Functions.create_function(:conflicts) do
  dispatch :conflicts do
    param 'Any', :resource
  end

  def conflicts(resource)
    fail(Puppet::ParseError, "Resource conflicts with #{resource}.") if call_function('defined', resource)
  end
end

# == Function: requires_realm( string $realm, [ string $message ] )
#
# Validate that the host realm is equal to some value.
# Abort catalog compilation if it is not.
#
# === Examples
#
#  # Fail unless running in Labs:
#  requires_realm('labs')
#
Puppet::Functions.create_function(:requires_realm) do
  dispatch :requires_realm do
    param 'String', :realm
    optional_param 'String', :message
  end

  def requires_realm(realm, message = nil)
    fail(Puppet::ParseError, message || "Realm '#{realm}' required.") unless realm == closure_scope.lookupvar('realm')
  end
end

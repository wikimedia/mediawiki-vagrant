# == Function: requires_ubuntu( string $version_predicate )
#
# Validate that the host Ubuntu version satisfies a version
# check. Abort catalog compilation if not.
#
# See the documentation for ubuntu_version() for supported
# predicate syntax.
#
# === Examples
#
#  # Fail unless version is Trusty
#  requires_ubuntu('trusty')
#
#  # Fail unless Trusty or newer
#  requires_ubuntu('> trusty')
#
Puppet::Functions.create_function(:requires_ubuntu) do
  dispatch :requires_ubuntu do
    param 'String', :version_predicate
  end

  def requires_ubuntu(version_predicate)
    fail(Puppet::ParseError, "Ubuntu #{version_predicate} required.") unless call_function('ubuntu_version', version_predicate)
  end
end

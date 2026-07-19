# == Function: requires_os( string $version_predicate )
#
# Validate that the host operating system version satisfies a version
# check. Abort catalog compilation if not.
#
# See the documentation for os_version() for supported predicate syntax.
#
# === Examples
#
#  # Fail unless version is exactly Debian jessie
#  requires_os('debian jessie')
#
#  # Fail unless Ubuntu Trusty or newer or Debian jessie or newer
#  requires_os('ubuntu >= trusty || debian >= jessie')
#
Puppet::Functions.create_function(:requires_os) do
  dispatch :requires_os do
    param 'String', :version_predicate
  end

  def requires_os(version_predicate)
    fail(Puppet::ParseError, "OS #{version_predicate} required.") unless call_function('os_version', version_predicate)
  end
end

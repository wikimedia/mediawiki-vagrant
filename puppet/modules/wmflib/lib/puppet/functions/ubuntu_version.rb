# == Function: ubuntu_version( string $version_predicate )
#
# Performs semantic Ubuntu version comparison.
#
# Takes a single string argument containing a comparison operator
# followed by an optional space, followed by a comparison target,
# provided as Ubuntu version number or release name.
#
# The host's Ubuntu version will be compared to to the comparison target
# using the specified operator, returning a boolean. If no operator is
# present, the equality operator is assumed.
#
# Release names are case-insensitive. The comparison operator and
# comparison target can be provided as two separate arguments, if you
# prefer.
#
# === Examples
#
#  # True if Precise or newer
#  ubuntu_version('>= precise')
#  ubuntu_version('>= 12.04.4')
#
#  # True if older than Utopic
#  ubuntu_version('< utopic')
#
#  # True if newer than Precise
#  ubuntu_version('> precise')
#
#  # True if Trusty or older
#  ubuntu_version('<= trusty')
#
#  # True if exactly Trusty
#  ubuntu_version('trusty')
#  ubuntu_version('== trusty')
#
#  # True if anything but Trusty
#  ubuntu_version('!trusty')
#  ubuntu_version('!= trusty')
#
require 'puppet/util/package'

UBUNTU_VERSION_RELEASES = {
  'hardy'    => '8.04',
  'intrepid' => '8.10',
  'jaunty'   => '9.04',
  'karmic'   => '9.10',
  'lucid'    => '10.04.4',
  'maverick' => '10.10',
  'natty'    => '11.04',
  'oneiric'  => '11.10',
  'precise'  => '12.04.4',
  'quantal'  => '12.10',
  'raring'   => '13.04',
  'saucy'    => '13.10',
  'trusty'   => '14.04',
  'utopic'   => '14.10',
}.freeze

Puppet::Functions.create_function(:ubuntu_version) do
  dispatch :ubuntu_version do
    param 'String', :arg1
    optional_param 'String', :arg2
  end

  def ubuntu_version(arg1, arg2 = nil)
    return false unless closure_scope.lookupvar('lsbdistid') == 'Ubuntu'

    expr = [arg1, arg2].compact.join(' ')
    unless expr =~ /^([<>=]*) *([\w\.]+)$/
      fail(ArgumentError, "ubuntu_version(): invalid expression '#{expr}'")
    end

    current = closure_scope.lookupvar('lsbdistrelease')
    operator = $1
    other = UBUNTU_VERSION_RELEASES[$2.downcase] || $2
    unless /^[\d.]+$/ =~ other
      fail(ArgumentError, "ubuntu_version(): unknown release '#{other}'")
    end

    cmp = Puppet::Util::Package.versioncmp(current, other)
    case operator
    when '', '=', '==' then cmp == 0
    when '!=', '!' then cmp != 0
    when '>'  then cmp == 1
    when '<'  then cmp == -1
    when '>=' then cmp >= 0
    when '<=' then cmp <= 0
    else fail(ArgumentError, "ubuntu_version(): unknown comparison operator '#{operator}'")
    end
  end
end

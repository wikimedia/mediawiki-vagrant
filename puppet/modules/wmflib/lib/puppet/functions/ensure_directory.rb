# == Function: ensure_directory( string|bool $ensure )
#
# Takes a generic 'ensure' parameter value and convert it to an
# appropriate value for use with a directory declaration.
#
# If $ensure is 'true' or 'present', the return value is 'directory'.
# Otherwise, the return value is the unmodified $ensure parameter.
#
# === Examples
#
#  # Sample class which creates or removes '/srv/redis'
#  # based on the class's generic $ensure parameter:
#  class redis( $ensure = present ) {
#    package { 'redis-server':
#      ensure => $ensure,
#    }
#    file { '/srv/redis':
#      ensure => ensure_directory($ensure),
#    }
#  }
#
Puppet::Functions.create_function(:ensure_directory) do
  dispatch :ensure_directory do
    param 'Any', :ensure_param
  end

  def ensure_directory(ensure_param)
    case ensure_param
    when 'present', 'true', true then 'directory'
    when 'absent', 'false', false then ensure_param
    else fail(ArgumentError, "ensure_directory(): invalid argument: '#{ensure_param}'.")
    end
  end
end

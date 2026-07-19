# == Function: ensure_service( string|bool $ensure )
#
# Takes a generic 'ensure' parameter value and convert it to an
# appropriate value for use with a service declaration.
#
# If $ensure is 'true' or 'present', the return value is 'running'.
# Otherwise, the return value is 'stopped'.
#
# === Examples
#
#  # Sample class which starts or stops the redis service
#  # based on the class's generic $ensure parameter:
#  class redis( $ensure = present ) {
#    package { 'redis-server':
#      ensure => $ensure,
#    }
#    service { 'redis':
#      ensure  => ensure_service($ensure),
#      require => Package['redis-server'],
#    }
#  }
#
Puppet::Functions.create_function(:ensure_service) do
  dispatch :ensure_service do
    param 'Any', :ensure_param
  end

  def ensure_service(ensure_param)
    case ensure_param
    when 'running', 'present', 'true', true then 'running'
    when 'stopped', 'absent', 'false', false then 'stopped'
    else fail(ArgumentError, "ensure_service(): invalid argument: '#{ensure_param}'.")
    end
  end
end

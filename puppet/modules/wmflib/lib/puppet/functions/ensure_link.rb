# == Function: ensure_link( string|bool $ensure )
#
# Takes a generic 'ensure' parameter value and convert it to an
# appropriate value for use with a symlink file declaration.
#
# If $ensure is 'true' or 'present', the return value is 'link'.
# Otherwise, the return value is the unmodified $ensure parameter.
#
# === Examples
#
#  # Sample class which creates or remove a symlink
#  # based on the class's generic $ensure parameter:
#  class rsyslog( $ensure = present ) {
#    package { 'rsyslog':
#      ensure => $ensure,
#    }
#    file { '/etc/rsyslog.d/50-default.conf':
#      ensure => ensure_link($ensure),
#      target => '/usr/share/rsyslog/50-default.conf',
#    }
#  }
#
Puppet::Functions.create_function(:ensure_link) do
  dispatch :ensure_link do
    param 'Any', :ensure_param
  end

  def ensure_link(ensure_param)
    case ensure_param
    when 'present', 'true', true then 'link'
    when 'absent', 'false', false then ensure_param
    else fail(ArgumentError, "ensure_link(): invalid argument: '#{ensure_param}'.")
    end
  end
end

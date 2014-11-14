# vim:sw=4 ts=4 sts=4 et:

# = Define: logstash::input::syslog
#
# Configure logstash to collect input as a syslog listener.
#
# == Parameters:
# - $ensure: Whether the config should exist. Default present.
# - $port: port to listen for syslog input on. Default 514.
# - $priority: Configuration loading priority. Default undef.
#
# == Sample usage:
#
#   logstash::input::syslog { 'syslog':
#       port => 514,
#   }
#
define logstash::input::syslog(
    $ensure   = present,
    $port     = 514,
    $priority = undef,
) {
    logstash::conf { "input_syslog_${title}":
        ensure   => $ensure,
        content  => template('logstash/input/syslog.erb'),
        priority => $priority,
    }
}

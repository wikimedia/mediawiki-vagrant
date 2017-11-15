# vim:sw=4 ts=4 sts=4 et:

# = Define: logstash::input::log4j
#
# Configure logstash to collect input as a log4j listener
#
# == Parameters:
# - $ensure: Whether the config should exist. Default present.
# - $port: port to listen for json input on. Default 12202.
# - $priority: Configuration loading priority. Default undef.
#
# == Sample usage:
#
#   logstash::input::log4j {
#       port => 4560,
#   }
#
define logstash::input::log4j(
    $ensure   = present,
    $port     = 4560,
    $priority = 10,
    $mode     = 'server',
    $host     = '0.0.0.0',
) {
    logstash::conf { "input_log4j_${title}":
        ensure   => $ensure,
        content  => template('logstash/input/log4j.erb'),
        priority => $priority,
    }
}


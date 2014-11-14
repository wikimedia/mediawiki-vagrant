# vim:sw=4 ts=4 sts=4 et:

# = Define: logstash::input::gelf
#
# Configure logstash to collect input as a gelf (graylog) listener.
#
# == Parameters:
# - $ensure: Whether the config should exist. Default present.
# - $port: port to listen for gelf input on. Default 12201.
# - $priority: Configuration loading priority. Default undef.
#
# == Sample usage:
#
#   logstash::input::gelf {
#       port => 12201,
#   }
#
define logstash::input::gelf(
    $ensure   = present,
    $port     = 12201,
    $priority = undef,
) {
    logstash::conf { "input_gelf_${title}":
        ensure   => $ensure,
        content  => template('logstash/input/gelf.erb'),
        priority => $priority,
    }
}

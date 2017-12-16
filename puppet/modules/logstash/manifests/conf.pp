# vim:sw=4 ts=4 sts=4 et:

# = Define: logstash::conf
#
# This resource type represents a collection of Logstash configuration
# directives.
#
# == Parameters:
#
# - $content: String containing Logstash configuration directives. Either this
#       or $source must be specified. Undefined by default.
# - $source: Path to file containing Logstash configuration directives. Either
#       this or $content must be specified. Undefined by default.
# - $priority: Configuration loading priority. Default 10.
# - $ensure: Whether the config should exist.
#
# == Sample usage:
#
#   logstash::conf { 'debug':
#     content => 'output { stdout { codec => rubydebug } }'
#   }
#
define logstash::conf(
    $ensure   = present,
    $content  = undef,
    $source   = undef,
    $priority = 10,
) {
    if $priority !~ Integer[0, 99] {
        fail('"priority" must be between 0 - 99')
    }
    $safe_name   = regsubst($title, '[\W_]', '-', 'G')
    $conf_file = sprintf('%02d-%s', $priority, $safe_name)

    file { "/etc/logstash/conf.d/${conf_file}.conf":
        ensure  => $ensure,
        content => $content,
        source  => $source,
        notify  => Service['logstash'],
    }
}

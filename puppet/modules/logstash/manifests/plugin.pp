# == Define: logstash::plugin
#
# A Logstash plugin.
#
# === Parameters
#
# [*title*]
#   Name of the plugin. Examples:
# logstash-filter-prune
#
define logstash::plugin(
    $ensure = present,
) {
    case $ensure {
        present: {
            exec { "install_logstash_plugin_${title}":
                command => "/usr/share/logstash/bin/logstash-plugin install '${title}'",
                require => Package['logstash'],
                notify  => Service['logstash'],
                unless  => "grep '^gem \"${title}\"$' /usr/share/logstash/Gemfile"
            }
        }
        absent: {
            exec { "uninstall_logstash_plugin_${title}":
                command => "/usr/share/logstash/bin/logstash-plugin remove '${title}'",
                require => Package['logstash'],
                notify  => Service['logstash'],
                onlyif  => "grep '^gem \"${title}\"$' /usr/share/logstash/Gemfile"
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}

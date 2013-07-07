# == Define: apache::mod
#
# Custom resource for Apache modules.
#
# === Parameters
#
# [*ensure*]
#   If 'present' or undefined, module will be enabled. If 'absent', module will
#   be disabled.
#
# [*mod*]
#   Module name
#
# === Examples
#
#  # enable mod_alias
#  apache::mod { 'alias': }
#
define apache::mod(
    $ensure = present,
    $mod    = $title,
) {
    include apache

    case $ensure {
        present: {
            exec { "a2enmod ${mod}":
                unless  => "apache2ctl -M | grep -q ${mod}",
                require => Package['apache2'],
                notify  => Service['apache2'],
            }
        }
        absent: {
            exec { "a2dismod ${mod}":
                onlyif  => "apache2ctl -M | grep -q ${mod}",
                require => Package['apache2'],
                notify  => Service['apache2'],
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}

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
    $ensure   = present,
    $mod      = $title,
    $loadfile = "${mod}.load",
) {
    include ::apache

    if $ensure == present {
        exec { "ensure_${ensure}_mod_${mod}":
            command => "/usr/sbin/a2enmod -qf ${mod}",
            creates => "/etc/apache2/mods-enabled/${loadfile}",
            require => Package['apache2'],
            notify  => Service['apache2'],
        }
    } elsif $ensure == absent {
        exec { "ensure_${ensure}_mod_${mod}":
            command => "/usr/sbin/a2dismod -qf ${mod}",
            onlyif  => "/usr/bin/test -L /etc/apache2/mods-enabled/${loadfile}",
            require => Package['apache2'],
            notify  => Service['apache2'],
        }
    } else {
        fail("'${ensure}' is not a valid value for ensure.")
    }
}

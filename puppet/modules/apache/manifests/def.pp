# == Define: apache::def
#
# This resource provides an easy way to declare a runtime parameter
# for Apache. It can then be used in Apache <IfDefine> checks.
#
# === Parameters
#
# [*ensure*]
#   If 'present', the environment variable will be defined; if absent,
#   undefined. The default is 'present'.
#
# === Example
#
#  apache::def { 'HHVM':
#    ensure => present,
#  }
#
define apache::def( $ensure = present ) {
    include ::apache

    $line = "export APACHE_ARGUMENTS=\"\$APACHE_ARGUMENTS -D ${title}\""

    if $ensure == present {
        exec { "apache_def_${title}":
            command => "/bin/echo '${line}' >> /etc/apache2/envvars",
            unless  => "/bin/grep -q '${line}' /etc/apache2/envvars",
            require => Package['apache2'],
            notify  => Service['apache2'],
        }
    } elsif $ensure == absent {
        exec { "apache_def_${title}":
            command => "/bin/sed -i '/${line}/d' /etc/apache2/envvars",
            onlyif  => "/bin/grep -q '${line}' /etc/apache2/envvars",
            require => Package['apache2'],
            notify  => Service['apache2'],
        }
    } else {
        fail('"ensure" must be "present" or "absent"')
    }
}

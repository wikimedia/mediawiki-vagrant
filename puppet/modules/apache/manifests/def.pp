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

    apache::env { "define_${title}":
        ensure  => $ensure,
        content => "export APACHE_ARGUMENTS=\"\$APACHE_ARGUMENTS -D ${title}\"\n"
    }
}

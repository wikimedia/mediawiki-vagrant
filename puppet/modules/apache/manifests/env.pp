# == Define: apache::env
#
# This resource provides an easy way to extend Apache's environment.
# It will create a file in /etc/apache2/env.d that will be loaded by
# Apache's init script and that can therefore define environment
# variables and additional command-line arguments.
#
# === Parameters
#
# [*ensure*]
#   If 'present', environment file will be created; if 'absent',
#   deleted. The default is 'present'.
#
# [*content*]
#   If defined, will be used as the content of the environment file.
#   Undefined by default. Either this or 'source' must be set.
#
# [*source*]
#   Path to file containing environment declarations. Undefined by
#   default. Either this or 'content' must be set.
#
# === Examples
#
#  Creates an Apache environment file that defines a runtime parameter
#  (via the -D command-line option). You can branch on its presence
#  via <IfDefine> directives:
#
#  apache::env { 'hhvm':
#    ensure  => present,
#    content => 'export APACHE_ARGUMENTS="$APACHE_ARGUMENTS -D HHVM"'
#  }
#
define apache::env(
    $ensure  = present,
    $content = undef,
    $source  = undef,
) {
    $title_safe  = regsubst($title, '[\W_]', '-', 'G')
    $link_ensure = $ensure ? {
        present => link,
        default => absent,
    }

    file { "/etc/apache2/env-available/${title_safe}":
        ensure  => $ensure,
        content => $content,
        source  => $source,
        require => File['/etc/apache2/envvars'],
        notify  => Service['apache2'],
    }

    file { "/etc/apache2/env-enabled/${title_safe}":
        ensure  => $link_ensure,
        target  => "/etc/apache2/env-available/${title_safe}",
        require => File["/etc/apache2/env-available/${title_safe}"],
        notify  => Service['apache2'],
    }
}

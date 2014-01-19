# == Define: misc::evergreen
#
# Refresh a service if its configuration files have changed.
#
# === Parameters
#
# [*service*]
#   Service name. Defaults to the resource title.
#
# [*executable*]
#   Base name of program's executable file. The process table will be
#   scanned for processes matching this name to determine if the service
#   needs to be refreshed. Defaults to the resource title.
#
# [*config_path*]
#   Path to service's configuration directory. Defaults to /etc/$title.
#   Multiple paths may be specified as an array.
#
# === Examples
#
#  misc::evergreen { 'apache2':
#    config_path => '/etc/apache2',
#  }
#
define misc::evergreen(
    $service    = $title,
    $executable = $title,
    $config_path = "/etc/${title}",
) {
    include ::misc

    exec { "check ${service} freshness":
        command => '/bin/true',
        unless  => "/usr/sbin/check_service_freshness ${executable} ${config_path}",
        require => File['/usr/sbin/check_service_freshness'],
        notify  => Service[$service],
    }
}

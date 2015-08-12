# == Define: service::gitupdate
#
# Schedules a MediaWiki service for repository and dependencies updating and
# service restart when 'vagrant git-update' is run. One can control the
# directory to update, whether the repository should be updated, whether the
# dependencies need an update and finally whether the service is to be restarted
# after the update, as well as the service name to restart.
#
# === Parameters
#
# [*title*]
#   The service's name. Used for the directory and restart name.
#
# [*dir*]
#   The directory where the service is located. If unspecified,
#   ${::service::root_dir}/${title} is used. Default: undef
#
# [*type*]
#   The type of the service, can be 'php' or 'nodejs'. This parameters is
#   relevant only if a dependencies update should be scheduled as well (cf. the
#   'update' parameter below). Default: undef
#
# [*pull*]
#   Whether to perform a git pull. Default: true
#
# [*update*]
#   Whether to perform a dependencies update. If set to true, the 'type'
#   parameter is obligatory. Default: false
#
# [*restart*]
#   Whether the service should also be restarted after the update process.
#   Default: false
#
# [*service_name*]
#   If the service needs to be restarted, but its service name differs from
#   $title, use this instead. Default: undef
#
# === Examples
#
# In the simplest form, if you specify only the title, only the service's git
# repository will be updated in ${::service::root_dir}/${title}:
#
#   service::gitupdate { 'myservice': }
#
# This will update the repository located in /vagrant/srv/myservice . If you
# have a PHP service with composer dependencies, use:
#
#   service::gitupdate { 'myservice':
#     type   => 'php',
#     update => true,
#   }
#
# In case your service is registered in the system under a different name, and
# needs to be restarted after the update, use:
#
#   service::gitupdate { 'myservice':
#     restart      => true,
#     service_name => 'other_name',
#   }
#
# This will cause vagrant git-update to issue the call 'service other_name
# restart'.
#
define service::gitupdate(
    $dir          = undef,
    $type         = undef,
    $pull         = true,
    $update       = false,
    $restart      = false,
    $service_name = undef,
) {

    require ::service

    # descern the update command to use
    $up_cmd = $type ? {
        'php'    => 'composer update --no-interaction --optimize-autoloader',
        'nodejs' => 'npm install --no-bin-links',
        default  => 'invalid'
    }
    if $update and $up_cmd == 'invalid' {
        fail("Invalid service type ${type} given, valid values are php, nodejs")
    }

    $srv_dir = $dir ? {
        undef   => "${::service::root_dir}/${title}",
        default => $dir
    }

    $restart_name = $service_name ? {
        undef   => $title,
        default => $service_name,
    }

    file { "${::service::conf_dir}/${title}.conf":
        ensure  => present,
        content => template('service/gitupdate.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

}

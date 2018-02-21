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
#   The type of the service, can be 'php', 'nodejs' or 'python'.
#   This parameter is relevant only if a dependencies update should be
#   scheduled as well (cf. the 'update' parameter below). Default: undef
#   NOTE:  python packages are installed into a virtualenv in 'editible'
#   mode.  That is, you can edit their checked out locations and still
#   see the effects in code run out of the virtualenv.
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
# Or if you have a Python service with pip dependencies specified in
# setup.py, use:
#
#   service::gitupdate { 'mypythonservice':
#     type   => 'python',
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
        'nodejs' => 'sudo rm -rf node_modules && npm install --no-bin-links',
        'python' => './virtualenv/bin/pip install -Ue .',
        default  => 'invalid'
    }
    if $update and $up_cmd == 'invalid' {
        fail("Invalid service type ${type} given, valid values are php, nodejs, python")
    }

    $srv_dir = $dir ? {
        undef   => "${::service::root_dir}/${title}",
        default => $dir
    }

    # Create a virtualenv in $srv_dir
    if $update and $type == 'python' {
        virtualenv::environment { "${srv_dir}/virtualenv":
            ensure   => 'present',
            # Packages will be installed by the $up_cmd
            # during vagrant git-update.
            packages => undef,
            timeout  => 600, # This can take a while
            # Most likely the $srv_dir will be in /vagrant,
            # so use $::share_owner.
            owner    => $::share_owner,
            group    => $::share_group,
        }
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

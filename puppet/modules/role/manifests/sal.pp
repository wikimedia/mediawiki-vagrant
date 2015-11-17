# == Class: role::sal
# Provisions the sal application
#
# === Parameters
# [*vhost_name*]
#   Vhost name of sal service. Default 'sal.local.wmftest.net'.
#
# [*dir*]
#   Deployment directory.
#
# [*env*]
#   Hash of environment settings.
#
class role::sal(
    $vhost_name,
    $dir,
    $env,
) {
    include ::elasticsearch

    git::clone { 'sal':
        directory => $dir,
        remote    => 'https://github.com/bd808/SAL.git',
    }

    php::composer::install { $dir:
        require => Git::Clone['sal'],
    }

    file { '/var/cache/sal':
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0770',
    }

    apache::site { $vhost_name:
        content => template('role/sal/apache.conf.erb'),
        require => Git::Clone['sal'],
    }
}

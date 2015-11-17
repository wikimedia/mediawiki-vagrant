# == Class: role::quips
# Provisions the quips application
#
# === Parameters
# [*vhost_name*]
#   Vhost name of quips service. Default 'quips.local.wmftest.net'.
#
# [*dir*]
#   Deployment directory.
#
# [*env*]
#   Hash of environment settings.
#
class role::quips(
    $vhost_name,
    $dir,
    $env,
) {
    include ::elasticsearch

    git::clone { 'quips':
        directory => $dir,
        remote    => 'https://github.com/bd808/quips.git',
    }

    php::composer::install { $dir:
        require => Git::Clone['quips'],
    }

    file { '/var/cache/quips':
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0770',
    }

    apache::site { $vhost_name:
        content => template('role/quips/apache.conf.erb'),
        require => Git::Clone['quips'],
    }
}

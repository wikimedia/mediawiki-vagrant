# vim:set sw=4 ts=4 sts=4 et:

# == Class: phabricator
#
# This class provisions an Apache vhost running the Phabricator application,
# creates the application database.
#
# === Parameters
#
# [*deploy_dir*]
#   Directory to clone Phabricator git repo in.
#
# [*vhost_name*]
#   Phabricator vhost name.
#
# [*remote*]
#   Phabricator git remote.
#
# [*branch*]
#   Phabricator branch to check out. If left undefined the default HEAD of the
#   remote will be used.
#
class phabricator(
    $deploy_dir,
    $vhost_name,
    $remote,
    $branch = undef,
){
    require ::arcanist
    include ::apache
    include ::apache::mod::rewrite
    include ::mysql
    include ::php

    require_package(
        'python-pygments',
        'python-phabricator',
        'php5-mailparse',
        'php5-ldap'
    )

    php::ini { 'phab_post_max_size':
        settings => [
            'post_max_size = 32M'
        ],
    }

    git::clone { 'phabricator':
        directory => "${deploy_dir}/phabricator",
        remote    => $remote,
        branch    => $branch,
    }

    service::gitupdate { 'phd':
        dir => "${deploy_dir}/phabricator",
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure   => present,
        # Load before MediaWiki vhost for Labs where the MediaWiki wildcard
        # vhost is likely to conflict with our hostname.
        priority => 40,
        content  => template('phabricator/apache.conf.erb'),
        require  => Class['::apache::mod::rewrite'],
    }

    phabricator::config { 'mysql.host':
        value => '127.0.0.1',
    }

    phabricator::config { 'mysql.port':
        value => 3306,
    }

    phabricator::config { 'mysql.pass':
        value => $::mysql::root_password,
    }

    phabricator::config { 'phabricator.base-uri':
        value => "http://${vhost_name}${::port_fragment}/",
    }

    phabricator::config { 'pygments.enabled':
        value => true,
    }

    phabricator::config { 'metamta.mail-adapter':
        value => 'PhabricatorMailImplementationTestAdapter',
    }

    phabricator::config { 'phabricator.developer-mode':
        value => true,
    }

    phabricator::config { 'storage.mysql-engine.max-size':
        value => 0,
    }

    file { '/var/repo':
        ensure => directory,
    }

    file { '/srv/phabfiles':
        ensure => directory,
        owner  => 'www-data',
    }

    phabricator::config { 'storage.local-disk.path':
        value   => '/srv/phabfiles',
        require => File['/srv/phabfiles'],
    }

    # Setup databases
    exec { 'phab_setup_db':
        command => "${deploy_dir}/phabricator/bin/storage upgrade --force",
        require => [
            Class['::mysql'],
            Phabricator::Config['mysql.host'],
            Phabricator::Config['mysql.pass'],
            Phabricator::Config['mysql.port'],
        ],
        unless  => "${deploy_dir}/phabricator/bin/storage status > /dev/null",
    }

    $phd = "${deploy_dir}/phabricator/bin/phd"
    service { 'phd':
        ensure   => running,
        enable   => true,
        provider => base,
        binary   => $phd,
        start    => "${phd} start",
        stop     => "${phd} stop",
        status   => "${phd} status | grep -v DEAD",
        require  => Exec['phab_setup_db'],
    }
}

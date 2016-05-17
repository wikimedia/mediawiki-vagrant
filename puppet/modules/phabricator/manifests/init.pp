# vim:set sw=4 ts=4 sts=4 et:

# == Class: phabricator
#
# This class provisions an Apache vhost running the Phabricator application,
# creates the application database.
#
class phabricator(
    $deploy_dir,
    $vhost_name,
){
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
        remote    => 'https://secure.phabricator.com/diffusion/P/phabricator.git',
        require   => Class['::arcanist'],
    }

    service::gitupdate { 'phd':
        dir => "${deploy_dir}/phabricator",
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure  => present,
        content => template('phabricator/apache.conf.erb'),
        require => Class['::apache::mod::rewrite'],
    }

    phabricator::config { 'mysql.host':
        value   => '127.0.0.1',
        require => Class['::mysql'],
    }

    phabricator::config { 'mysql.port':
        value   => 3306,
        require => Phabricator::Config['mysql.host'],
    }

    phabricator::config { 'mysql.pass':
        value   => $::mysql::root_password,
        require => Phabricator::Config['mysql.port'],
    }

    phabricator::config { 'phabricator.base-uri':
        value => "http://${vhost_name}${::port_fragment}/",
    }

    phabricator::config { 'pygments.enabled':
        value   => true,
        require => Package['python-pygments'],
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

    # Setup databases
    exec { 'phab_setup_db':
        command => "${deploy_dir}/phabricator/bin/storage upgrade --force",
        require => Phabricator::Config['mysql.pass'],
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

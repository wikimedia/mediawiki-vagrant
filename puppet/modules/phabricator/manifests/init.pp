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
    include ::elasticsearch
    include ::mysql
    include ::php

    package { [
        'python-pygments',
        'python-phabricator',
        'php5-mailparse',
        'php5-ldap'
    ]:
        ensure => present,
    }

    git::clone { 'https://github.com/phacility/phabricator':
        directory => "${deploy_dir}/phabricator",
        remote    => 'https://github.com/phacility/phabricator',
        require   => Class['::arcanist'],
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure  => present,
        content => template('phabricator/apache.conf.erb'),
        require => Class['::apache::mod::rewrite'],
    }

    phabricator::config { 'mysql.pass':
        value   => $::mysql::root_password,
        require => Class['::mysql'],
    }

    phabricator::config { 'phabricator.base-uri':
        value => "http://${vhost_name}${::port_fragment}/",
    }

    phabricator::config { 'search.elastic.host':
        value   => 'http://localhost:9200',
        require => Class['::elasticsearch'],
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

    file { "/var/repo":
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
        enable   => true,
        ensure   => running,
        provider => base,
        binary   => $phd,
        start    => "${phd} start",
        stop     => "${phd} stop",
        status   => "${phd} status | grep -v DEAD",
        require  => Exec['phab_setup_db'],
    }
}

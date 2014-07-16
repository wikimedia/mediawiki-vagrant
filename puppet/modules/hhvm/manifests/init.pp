# == Class: hhvm
#
# Configures the HipHop Virtual Machine for PHP, a fast PHP interpreter
# that is mostly compatible with the Zend interpreter. This module is a
# work-in-progress.
#
class hhvm {
    include ::apache
    include ::apache::mod::proxy_fcgi

    package { [ 'hhvm', 'hhvm-dev', 'hhvm-fss', 'hhvm-luasandbox', 'hhvm-wikidiff2' ]:
        before => Service['hhvm'],
    }

    env::alternative { 'hhvm_as_default_php':
        alternative => 'php',
        target      => '/usr/bin/hhvm',
        priority    => 20,
        require     => Package['hhvm'],
    }

    file { '/etc/hhvm':
        ensure => directory,
    }

    file { '/etc/hhvm/config.hdf':
        content => template('hhvm/config.hdf.erb'),
        require => Package['hhvm'],
        notify  => Service['hhvm'],
    }

    file { '/etc/hhvm/php.ini':
        content => template('hhvm/php.ini.erb'),
        require => Package['hhvm'],
        notify  => Service['hhvm'],
    }

    file { '/etc/init/hhvm.conf':
        ensure  => file,
        content => template('hhvm/hhvm.conf.erb'),
        require => [ Env::Alternative['hhvm_as_default_php'], File['/etc/hhvm/config.hdf'] ],
        notify  => Service['hhvm'],
    }

    service { 'hhvm':
        ensure   => running,
        provider => upstart,
        require  => File['/etc/init/hhvm.conf'],
    }

    file { '/usr/local/bin/hhvmsh':
        source => 'puppet:///modules/hhvm/hhvmsh',
        mode   => '0555',
    }

    apache::site { 'hhvm_admin':
        ensure  => present,
        content => template('hhvm/admin-apache-site.erb'),
        require => Class['::apache::mod::proxy_fcgi'],
    }
}

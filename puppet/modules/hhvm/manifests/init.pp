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

    file { '/etc/hhvm':
        ensure => directory,
    }

    file { '/etc/hhvm/config.hdf':
        content => template('hhvm/config.hdf.erb'),
        require => Package['hhvm'],
        notify  => Service['hhvm'],
    }

    file { '/etc/init/hhvm.conf':
        ensure  => file,
        content => template('hhvm/hhvm.conf.erb'),
        require => File['/etc/hhvm/config.hdf'],
        notify  => Service['hhvm'],
    }

    service { 'hhvm':
        ensure   => running,
        provider => upstart,
        require  => File['/etc/init/hhvm.conf'],
    }
}

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

    package { 'hhvm-nightly': ensure => absent, }

    # Define an 'HHVM' flag, the presence of which can be checked
    # with <IfDefine> directives. This allows Apache site config
    # files to provide HHVM-specific configuration blocks.
    apache::env { 'hhvm':
        content => 'export APACHE_ARGUMENTS="${APACHE_ARGUMENTS:- }-D HHVM"',
        require => Service['hhvm'],
    }

    file { '/etc/hhvm':
        ensure => directory,
    }

    file { '/etc/hhvm/config.hdf':
        content => template( 'hhvm/config.hdf.erb'),
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

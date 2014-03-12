# == Class: hhvm
#
# Configures the HipHop Virtual Machine for PHP, a fast PHP interpreter
# that is mostly compatible with the Zend interpreter. This module is a
# work-in-progress.
#
class hhvm {
    include ::apache
    include ::apache::mods::actions
    include ::apache::mods::alias
    include ::apache::mods::fastcgi

    # 12.04 requires updated boost packages
    apt::ppa { 'mapnik/boost': }

    package { 'hhvm-fastcgi':
        require => Apache::Mod['actions', 'alias', 'fastcgi'],
    }

    # Define an 'HHVM' flag, the presence of which can be checked
    # with <IfDefine> directives. This allows Apache site config
    # files to provide HHVM-specific configuration blocks.
    apache::env { 'hhvm':
        content => 'export APACHE_ARGUMENTS="${APACHE_ARGUMENTS:- }-D HHVM"',
        require => Service['hhvm'],
    }

    file { '/etc/hhvm/server.hdf':
        ensure  => file,
        content => template( 'hhvm/server.hdf.erb'),
        require => Package['hhvm-fastcgi'],
        notify  => Service['hhvm'],
    }

    service { 'hhvm':
        ensure   => running,
        provider => debian,
        enable   => true,
        require  => File['/etc/hhvm/server.hdf'],
    }
}

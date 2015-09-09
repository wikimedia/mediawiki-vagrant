# == Class: Varnish
#
# This Puppet class installs and configures a Varnish instance
#
class varnish {
    package { 'varnish':
        ensure => 'present'
    }

    file { '/etc/varnish/default.vcl':
        source  => 'puppet:///modules/varnish/default.vcl',
        mode    => '0644',
        require => Package['varnish'],
    }

    service { 'varnish':
        ensure    => running,
        provider  => init,
        require   => Package['varnish'],
        subscribe => File['/etc/varnish/default.vcl'],
    }
}

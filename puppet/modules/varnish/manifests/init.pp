# == Class: varnish
#
# This Puppet class installs and configures a Varnish instance.
#
# Additional configuration can be managed using `varnish::config` and will be
# applied according to the given `order`. Default configuration has an order
# of 5, so anything of a lesser order will be applied first, greater next.
# Typical Varnish rules of precedence apply when evaluating multiple
# configuration and subroutines.
#
# See https://www.varnish-cache.org/docs/3.0/reference/vcl.html#multiple-subroutines
#
class varnish {
    require_package('apt-transport-https')

    # set up the repo pubkey
    file  { '/usr/local/share/varnish-cache.org-pubkey.txt':
        source => 'puppet:///modules/varnish/varnish-cache.org-pubkey.txt',
        owner  => 'root',
        group  => 'root',
    }

    # add the varnish repo list file
    file { '/etc/apt/sources.list.d/varnish-cache.list':
        source => 'puppet:///modules/varnish/varnish-cache.list',
        owner  => 'root',
        group  => 'root',
    }

    # add the key and update
    exec { 'add_varnish_apt_key_and_update':
        command => '/usr/bin/apt-key add /usr/local/share/varnish-cache.org-pubkey.txt && /usr/bin/apt-get update',
        require => [
            File['/usr/local/share/varnish-cache.org-pubkey.txt'],
            File['/etc/apt/sources.list.d/varnish-cache.list'],
        ],
        creates => '/var/lib/apt/lists/repo.varnish-cache.org_ubuntu_dists_trusty_InRelease',
    }

    package { 'varnish':
        ensure  => 'latest',
        require => [
            Package['apt-transport-https'],
            Exec['add_varnish_apt_key_and_update'],
        ]
    }

    $conf = '/etc/varnish/conf-d.vcl'
    $confd = '/etc/varnish/conf.d'

    # This level of include indirection is annoying but necessary to escape
    # endless Puppet file/file_line conflicts.
    file { '/etc/varnish/default.vcl':
        content => "vcl 4.0;\ninclude \"${conf}\";\n",
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        require => Package['varnish'],
    }

    file { $conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['varnish'],
    }

    file { $confd:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['varnish'],
    }

    service { 'varnish':
        ensure    => running,
        provider  => init,
        require   => Package['varnish'],
        subscribe => File[$conf],
    }

    # Ensure included config order is respected by sorting default.vcl
    # (see varnish::config)
    exec { 'varnish_sort_confd':
        command     => "sort -o '${conf}' '${conf}'",
        refreshonly => true,
        notify      => Service['varnish'],
    }

    varnish::backend { 'default':
        host  => '127.0.0.1',
        port  => '8080',
        order => 20,
    }

    # acl for "purge": open to only localhost
    varnish::config { 'acl-purge':
        content => "vcl 4.0;\nacl purge { \"127.0.0.1\"; }",
        order   => 10,
    }

    varnish::config { 'default-subs':
        source => 'puppet:///modules/varnish/default-subs.vcl',
        order  => 50,
    }
}

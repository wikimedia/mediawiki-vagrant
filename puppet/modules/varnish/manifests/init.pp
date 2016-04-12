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
    group { 'varnish':
        ensure => present,
    }

    user { 'varnish':
        ensure  => present,
        home    => '/home/varnish',
        gid     => 'varnish',
        require => Group['varnish'],
    }

    file { '/etc/varnish':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # Dependencies to build varnish
    require_package('libncurses-dev')
    require_package('libpcre3-dev')
    require_package('libedit-dev')

    # We need to build from source because the tbf vmod needs the
    # built source, can't rely only on the headers
    git::clone { 'Varnish-Cache':
        branch    => '4.1',
        directory => '/tmp/Varnish-Cache',
        remote    => 'https://github.com/varnish/Varnish-Cache',
    }

    file { '/tmp/build-varnish.sh':
        source => 'puppet:///modules/varnish/build-varnish.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_varnish':
        command => '/tmp/build-varnish.sh',
        creates => '/usr/local/sbin/varnishd',
        require => [
            File['/tmp/build-varnish.sh'],
            Git::Clone['Varnish-Cache'],
            Package['libncurses-dev'],
            Package['libpcre3-dev'],
            Package['libedit-dev'],
        ],
        user    => 'root',
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
        require => Exec['build_varnish'],
    }

    file { $conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
            Exec['build_varnish'],
            File['/etc/varnish'],
        ],
    }

    file { $confd:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => [
            Exec['build_varnish'],
            File['/etc/varnish'],
        ],
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

    # Build and install tbf vmod
    require_package('libdb-dev')
    require_package('python-docutils')
    require_package('automake')
    require_package('libtool')

    git::clone { 'libvmod-tbf':
        branch    => 'varnish-4.1',
        directory => '/tmp/libvmod-tbf',
        remote    => 'git://git.gnu.org.ua/vmod-tbf.git',
    }

    file { '/tmp/build-tbf.sh':
        source => 'puppet:///modules/varnish/build-tbf.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_tbf':
        command => '/tmp/build-tbf.sh',
        creates => '/usr/local/lib/varnish/vmods/libvmod_tbf.so',
        require => [
            Exec['build_varnish'],
            Package['libdb-dev'],
            File['/tmp/build-tbf.sh'],
            Git::Clone['libvmod-tbf'],
        ],
        user    => 'root',
    }

    file { '/etc/varnish/secret':
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => '9cd5ac29-39c9-4b8b-98a8-d042de4f92c2',
        require => File['/etc/varnish'],
    }

    file { '/var/run/varnish':
        ensure => directory,
        owner  => 'varnish',
        group  => 'varnish',
        mode   => '0755',
    }

    file { '/usr/local/var':
        ensure => directory,
        owner  => 'varnish',
        group  => 'varnish',
        mode   => '0755',
    }

    file { '/usr/local/var/varnish':
        ensure  => directory,
        owner   => 'varnish',
        group   => 'varnish',
        mode    => '0755',
        require => File['/usr/local/var'],
    }

    file { '/usr/local/var/varnish/mediawiki-vagrant':
        ensure  => directory,
        owner   => 'varnish',
        group   => 'varnish',
        mode    => '0755',
        require => File['/usr/local/var/varnish'],
    }

    # Build and install vmods (which include xkey)
    git::clone { 'varnish-modules':
        directory => '/tmp/varnish-modules',
        remote    => 'https://github.com/varnish/varnish-modules',
    }

    file { '/tmp/build-varnish-modules.sh':
        source => 'puppet:///modules/varnish/build-varnish-modules.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_varnish_modules':
        command => '/tmp/build-varnish-modules.sh',
        creates => '/usr/local/lib/varnish/vmods/libvmod_xkey.so',
        require => [
            Exec['build_varnish'],
            File['/tmp/build-varnish-modules.sh'],
            Git::Clone['varnish-modules'],
        ],
        user    => 'root',
    }

    file { '/etc/init/varnish.conf':
        ensure  => present,
        content => template('varnish/upstart.erb'),
        mode    => '0444',
    }

    service { 'varnish':
        ensure    => running,
        provider  => 'upstart',
        require   => [
            Exec[
                'build_varnish',
                'build_tbf',
                'build_varnish_modules'
            ],
            File[
                '/var/run/varnish',
                '/etc/init/varnish.conf',
                '/etc/varnish/secret',
                '/usr/local/var/varnish/mediawiki-vagrant'
            ],
        ],
        subscribe => File[$conf],
    }
}

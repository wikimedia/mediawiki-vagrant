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
    require ::role::elk

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

    file { '/srv/varnish-build':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # Dependencies to build varnish
    require_package('pkg-config')
    require_package('libncurses-dev')
    require_package('libpcre3-dev')
    require_package('libedit-dev')
    require_package('python3-logstash')

    # We need to build from source because the tbf vmod needs the
    # built source, can't rely only on the headers
    git::clone { 'Varnish-Cache':
        branch    => 'varnish-4.1.3',
        directory => '/srv/varnish-build/Varnish-Cache',
        remote    => 'https://github.com/varnishcache/varnish-cache',
    }

    file { '/srv/varnish-build/build-varnish.sh':
        source => 'puppet:///modules/varnish/build-varnish.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_varnish':
        command => '/srv/varnish-build/build-varnish.sh',
        creates => '/usr/local/sbin/varnishd',
        require => [
            File['/srv/varnish-build/build-varnish.sh'],
            Git::Clone['Varnish-Cache'],
            Package['pkg-config'],
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
        port  => $::forwarded_port,
        order => 20,
    }

    # acl for "purge": open to only localhost
    varnish::config { 'acl-purge':
        content => "vcl 4.0;\nacl purge { \"127.0.0.1\"; }",
        order   => 10,
    }

    varnish::config { 'default-subs':
        content => template('varnish/default-subs.vcl.erb'),
        order   => 50,
    }

    $errorpage = {
        title => 'Mediawiki Error',
        pagetitle => 'Error',
        logo_link => '/',
        logo_src => '/mediawiki-vagrant.png',
        logo_srcset => '/mediawiki-vagrant-2x.png 2x',
        logo_alt => 'Mediawiki',
        content  => '<p>Our servers are currently under maintenance or experiencing a technical problem. Please <a href="" title="Reload this page" onclick="window.location.reload(false); return false">try again</a> in a few&nbsp;minutes.</p><p>See the error message at the bottom of this page for more&nbsp;information.</p>',
        # Placeholder "%error%" substituted at runtime in errorpage.inc.vcl
        footer   => '<p>If you report this error to the Mediawiki System Administrators, please include the details below.</p><p class="text-muted"><code>%error%</code></p>',
    }
    $errorpage_html = template('mediawiki/errorpage.html.erb')

    varnish::config { 'errorpage':
        content => template('varnish/errorpage.inc.vcl.erb'),
        order   => 10,
    }

    # Build and install tbf vmod
    require_package('libdb-dev')
    require_package('python-docutils')
    require_package('automake')
    require_package('libtool')

    git::clone { 'libvmod-tbf':
        branch    => 'varnish-4.1',
        directory => '/srv/varnish-build/libvmod-tbf',
        remote    => 'http://git.gnu.org.ua/cgit/vmod-tbf.git',
    }

    file { '/srv/varnish-build/build-tbf.sh':
        source => 'puppet:///modules/varnish/build-tbf.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_tbf':
        command => '/srv/varnish-build/build-tbf.sh',
        creates => '/usr/local/lib/varnish/vmods/libvmod_tbf.so',
        require => [
            Exec['build_varnish'],
            Package['libdb-dev'],
            File['/srv/varnish-build/build-tbf.sh'],
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
        branch    => 'varnish-modules-0.9.1',
        directory => '/srv/varnish-build/varnish-modules',
        remote    => 'https://github.com/varnish/varnish-modules',
    }

    file { '/srv/varnish-build/build-varnish-modules.sh':
        source => 'puppet:///modules/varnish/build-varnish-modules.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    exec { 'build_varnish_modules':
        command => '/srv/varnish-build/build-varnish-modules.sh',
        creates => '/usr/local/lib/varnish/vmods/libvmod_xkey.so',
        require => [
            Exec['build_varnish'],
            File['/srv/varnish-build/build-varnish-modules.sh'],
            Git::Clone['varnish-modules'],
        ],
        user    => 'root',
    }

    file { '/usr/local/lib/python3.5/dist-packages/wikimedia_varnishlogconsumer.py':
        source => 'puppet:///modules/varnish/wikimedia_varnishlogconsumer.py',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    file { '/usr/local/bin/varnishslowlog':
        source => 'puppet:///modules/varnish/varnishslowlog.py',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/usr/local/bin/varnishospital':
        source => 'puppet:///modules/varnish/varnishospital.py',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    systemd::service { 'varnishslowlog':
        ensure         => 'present',
        require        => File['/usr/local/bin/varnishslowlog'],
        service_params => {
            subscribe => File['/usr/local/bin/varnishslowlog'],
        },
    }

    file { '/etc/mtail/varnish':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/usr/local/bin/varnishmtail':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///modules/varnish/varnishmtail',
        notify => Systemd::Service['varnishmtail'],
    }

    systemd::service { 'varnishmtail':
        ensure        => present,
        template_name => 'varnishmtail',
        require       => File['/usr/local/bin/varnishmtail'],
    }

    mtail::program { 'varnishbackendtiming':
        source      => 'puppet:///modules/mtail/programs/varnishbackendtiming.mtail',
        notify      => Service['varnishmtail'],
        destination => '/etc/mtail/varnish',
        require     => File['/etc/mtail/varnish'],
    }

    mtail::program { 'varnishmedia':
        source      => 'puppet:///modules/mtail/programs/varnishmedia.mtail',
        notify      => Service['varnishmtail'],
        destination => '/etc/mtail/varnish',
        require     => File['/etc/mtail/varnish'],
    }

    mtail::program { 'varnishrls':
        source      => 'puppet:///modules/mtail/programs/varnishrls.mtail',
        notify      => Service['varnishmtail'],
        destination => '/etc/mtail/varnish',
        require     => File['/etc/mtail/varnish'],
    }

    systemd::service { 'varnish':
        ensure         => 'present',
        require        => [
            Exec[
                'build_varnish',
                'build_tbf',
                'build_varnish_modules'
            ],
            File[
                '/var/run/varnish',
                '/etc/varnish/secret',
                '/usr/local/var/varnish/mediawiki-vagrant'
            ],
        ],
        service_params => {
            subscribe => File[$conf],
        },
    }

    $example_url = "http://${::role::mediawiki::hostname}:6081/"
    mediawiki::import::text { 'VagrantRoleVarnish':
        content => template('role/varnish/VagrantRoleVarnish.wiki.erb'),
    }
}

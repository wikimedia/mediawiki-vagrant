# Class haproxy

class haproxy(
    $template = 'haproxy/haproxy.cfg.erb',
    $socket   = '/run/haproxy/haproxy.sock',
    $pid      = '/run/haproxy/haproxy.pid',
) {

    package { [
        'socat',
        'haproxy',
    ]:
        ensure => present,
    }

    if $socket == '/run/haproxy/haproxy.sock' or $socket == '/run/haproxy/haproxy.pid' {
        file { '/run/haproxy':
            ensure  => directory,
            mode    => '0775',
            owner   => 'root',
            group   => 'haproxy',
            require => Package['haproxy']
        }
    }

    file { '/etc/haproxy/conf.d':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['haproxy']
    }

    file { '/etc/haproxy/haproxy.cfg':
        ensure  => present,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template($template),
        notify  => Exec['restart-haproxy'],
        require => Package['haproxy']
    }

    exec { 'restart-haproxy':
        command     => '/bin/systemctl restart haproxy',
        refreshonly => true,
    }

    # defaults file cannot be dynamic anymore on systemd
    # pregenerate them on systemd start/reload
    file { '/usr/local/bin/generate_haproxy_default.sh':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/haproxy/generate_haproxy_default.sh',
    }

    # TODO: this should use the general systemd puppet abstraction instead
    file { '/lib/systemd/system/haproxy.service':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('haproxy/haproxy.service.erb'),
        require => File['/usr/local/bin/generate_haproxy_default.sh'],
        notify  => Exec['/bin/systemctl daemon-reload'],
    }

    exec { '/bin/systemctl daemon-reload':
        user        => 'root',
        refreshonly => true,
    }

    rsyslog::conf { 'haproxy':
        source   => 'puppet:///modules/haproxy/rsyslog.conf',
        priority => 40,
    }

    mtail::program { 'haproxy':
        ensure => present,
        source => 'puppet:///modules/mtail/programs/haproxy.mtail',
    }
}

# == Class: uwsgi
#
# uWSGI is a web application server, typically used in conjunction with
# Nginx to serve Python web applications, but capable of interoperating
# with a broad range of languages, protocols, and platforms.
#
class uwsgi {
    $plugins = [
        'uwsgi-plugin-python',
        'uwsgi-plugin-python3',
        'uwsgi-plugin-rack-ruby2.5',
    ]

    package { [ 'uwsgi', 'uwsgi-dbg' ]: }
    package { $plugins: }

    exec { 'remove_uwsgi_initd':
        command => '/usr/sbin/update-rc.d -f uwsgi remove',
        onlyif  => '/usr/sbin/update-rc.d -n -f uwsgi remove | /bin/grep -Pq rc..d',
        require => Package['uwsgi'],
    }

    # Stop the default uwsgi service since it is incompatible with
    # our multi instance setup. The update-rc.d isn't good enough on
    # systemd instances
    service { 'uwsgi':
        ensure  => stopped,
        enable  => false,
        require => Package['uwsgi'],
    }

    file { [ '/etc/uwsgi/apps-available', '/etc/uwsgi/apps-enabled' ]:
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        require => Package['uwsgi', $plugins],
    }

    file { '/run/uwsgi':
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0755',
    }

    file { '/etc/tmpfiles.d/uwsgi-startup.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => 'd /run/uwsgi 0755 www-data www-data',
    }
}

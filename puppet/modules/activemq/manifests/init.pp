# == Class: activemq
#
# Provisions Apache ActiveMQ
#
class activemq(
    $version  = '5.9.1',
    $hostname = '127.0.0.1',
    $port     = '61613',
) {
    $pkgname = "apache-activemq-${version}"
    $mirror = "http://mirrors.ibiblio.org/apache/activemq/${version}/${pkgname}-bin.tar.gz"

    $destdir = '/usr/local'
    $pkgdir = "${destdir}/${pkgname}"

    tarball { $pkgname:
        ensure  => present,
        source  => $mirror,
        storage => '/vagrant/apt-cache',
        path    => $destdir,
        creates => $pkgdir,
    }

    $config = '/etc/activemq.xml'

    file { $config:
        owner   => root,
        group   => root,
        content => template('activemq/activemq.xml.erb'),
    }

    package { 'default-jre-headless':
        ensure => present,
    }

    user { 'activemq':
        ensure     => present,
        managehome => true,
        home       => '/home/activemq',
    }

    file { [ "${pkgdir}/data", "${pkgdir}/tmp" ]:
        ensure  => directory,
        owner   => 'activemq',
        group   => 'activemq',
        mode    => '0770',
        recurse => true,
        require => Tarball[$pkgname],
    }

    service { 'activemq':
        ensure    => running,
        provider  => 'upstart',
        require   => [
            Package['default-jre-headless'],
            Tarball[$pkgname],
            File["${pkgdir}/data"],
            User['activemq'],
        ],
        subscribe => [
            File['/etc/init/activemq.conf'],
            File[$config],
        ],
    }

    file { '/etc/init/activemq.conf':
        content => template('activemq/activemq-upstart.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }
}

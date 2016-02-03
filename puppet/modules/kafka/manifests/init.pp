# == Class: Kafka
#
class kafka {
    require ::service

    require_package('zookeeper-server')
    require_package('kafka-server')
    require_package('kafka-cli')
    require_package('kafkacat')

    exec { 'zookeeper-server-init':
        command => '/usr/bin/service zookeeper-server init',
        unless  => '/usr/bin/test -d /var/lib/zookeeper/version-2',
        require => Package['zookeeper-server']
    }

    service { 'zookeeper-server':
        ensure  => 'running',
        enable  => true,
        require => Exec['zookeeper-server-init'],
    }

    file { '/etc/default/kafka':
        source  => 'puppet:///modules/kafka/default',
        require => Package['kafka-server'],
        owner   => 'root',
        group   => 'root',
    }

    service { 'kafka':
        ensure  => 'running',
        enable  => true,
        require => [
            File['/etc/default/kafka'],
            Package['zookeeper-server']
        ],
    }

    # If kafka starts before zookeeper it fails
    exec { 'kafka-after-zookeper':
        command => 'update-rc.d -f kafka remove && update-rc.d kafka defaults 30',
        unless  => 'test -f /etc/rc3.d/S30kafka',
        require => Package['kafka-server'],
    }

    git::clone { 'mediawiki/event-schemas':
        directory => "${::service::root_dir}/event-schemas"
    }

    service::gitupdate { 'event-schemas': }
}

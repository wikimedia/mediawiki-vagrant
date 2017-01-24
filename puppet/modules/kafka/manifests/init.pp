# == Class: Kafka
#
class kafka {
    require ::service
    require ::mediawiki::ready_service

    require_package('openjdk-7-jdk')
    require_package('zookeeper-server')
    require_package('confluent-kafka-2.11.7')
    require_package('kafkacat')

    group { 'kafka':
        ensure  => 'present',
        system  => true,
        require => Package['confluent-kafka-2.11.7'],
    }
    # Kafka system user
    user { 'kafka':
        gid        => 'kafka',
        shell      => '/bin/false',
        home       => '/nonexistent',
        comment    => 'Apache Kafka',
        system     => true,
        managehome => false,
        require    => Group['kafka'],
    }

    file { '/usr/local/bin/kafka':
        source => 'puppet:///modules/kafka/kafka.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # Install handy env vars in all shells so we don't have to specify
    # broker and zookeeper args every time using kafka CLI.
    file { '/etc/profile.d/kafka.sh':
        source => 'puppet:///modules/kafka/kafka.profile.sh',
    }

    file { '/etc/kafka/server.properties':
        ensure => 'present',
        source => 'puppet:///modules/kafka/server.properties',
        mode   => '0444',
    }

    file { ['/var/log/kafka', '/var/lib/kafka']:
        ensure => 'directory',
        owner  => 'kafka',
        group  => 'kafka',
        mode   => '0755',
    }

    exec { 'zookeeper-server-init':
        command => '/etc/init.d/zookeeper-server init',
        unless  => '/usr/bin/test -d /var/lib/zookeeper/version-2',
        require => Package['zookeeper-server']
    }

    service { 'zookeeper-server':
        ensure  => 'running',
        enable  => true,
        require => Exec['zookeeper-server-init'],
    }

    systemd::service { 'kafka':
        ensure         => 'present',
        service_params => {
            require   => [
                User['kafka'],
                Service['zookeeper-server'],
            ],
            subscribe => File['/etc/kafka/server.properties'],
        },
    }
}

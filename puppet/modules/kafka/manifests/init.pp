# == Class: Kafka
#
class kafka {
    require ::service
    require ::mediawiki::ready_service
    require ::kafka::repository

    $kafka_package = 'confluent-kafka-2.11'
    require_package('openjdk-8-jdk')
    require_package('zookeeperd')
    require_package($kafka_package)
    require_package('kafkacat')

    $logdir = '/var/log/kafka'

    group { 'kafka':
        ensure  => 'present',
        system  => true,
        require => Package[$kafka_package],
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
        ensure  => 'present',
        source  => 'puppet:///modules/kafka/server.properties',
        mode    => '0444',
        require => Package[$kafka_package],
    }

    file { '/etc/kafka/log4j.properties':
      ensure  => 'present',
      content => template('kafka/log4j.properties.erb'),
      mode    => '0444',
      require => Package[$kafka_package],
    }

    file { [$logdir, '/var/lib/kafka']:
        ensure  => 'directory',
        owner   => 'kafka',
        group   => 'kafka',
        mode    => '0755',
        require => Package[$kafka_package],
    }

    service { 'zookeeper':
        ensure  => 'running',
        enable  => true,
        require => Package['zookeeperd']
    }

    systemd::service { 'kafka':
        ensure         => 'present',
        service_params => {
            require   => [
                User['kafka'],
                Service['zookeeper'],
                Package[$kafka_package],
            ],
            subscribe => [
                File['/etc/kafka/server.properties'],
                File['/etc/kafka/log4j.properties'],
            ]
        },
    }
}

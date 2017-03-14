# == Class: Elasticsearch
#
# Elasticsearch is a powerful open source search and analytics
# engine, much like Solr, but with a more user-friendly inteface.
#
class elasticsearch {
    if $::lsbdistcodename == 'jessie' {
        # Elasticsearch 5.x is currently in the experiemental repository
        file { '/etc/apt/sources.list.d/wikimedia-experimental.list':
            ensure  => present,
            content => template('elasticsearch/wikimedia-experimental.list.erb'),
            before  => Exec['apt-get update'],
            # Does this work to force apt-get update beyond the scheduled daily run?
            notify  => Exec['apt-get update'],
        }
    } else {
        # For openjdk-8
        apt::ppa { 'openjdk-r/ppa': }

        # elasticsearch 5.x packages. One potential downside here is this will auto-upgrade
        # to new releases of elasticsearch before we release custom plugins. Switching to
        # .deb packaging for plugins should fix that, as it wont upgrade if the version
        # constraints aren't met.
        file { '/usr/local/share/elasticsearch-pubkey.asc':
            source => 'puppet:///modules/elasticsearch/elasticsearch-pubkey.asc',
            owner  => 'root',
            group  => 'root',
            before => File['/etc/apt/sources.list.d/elasticsearch.list'],
            notify => Exec['add_elasticsearch_apt_key'],
        }
        exec { 'add_elasticsearch_apt_key':
            command     => '/usr/bin/apt-key add /usr/local/share/elasticsearch-pubkey.asc',
            before      => File['/etc/apt/sources.list.d/elasticsearch.list'],
            refreshonly => true,
        }
        file { '/etc/apt/sources.list.d/elasticsearch.list':
            content => 'deb https://artifacts.elastic.co/packages/5.x/apt stable main',
            before  => Exec['apt-get update'],
            notify  => Exec['apt-get update'],
        }
        # The 5.x package from elasticsearch needs to be pinned higher than default wikimedia
        apt::pin { 'elasticsearch':
            package  => 'elasticsearch',
            pin      => 'release o=elastic',
            priority => 1010,
            before   => Package['elasticsearch'],
        }

    }

    require_package('openjdk-8-jre-headless')

    package { 'elasticsearch':
        ensure  => latest,
        require => [
            Exec['apt-get update'],
        ],
    }

    # This is needed when upgrading from 2.x to 5.x, the directory
    # ends up owned by root and elasticsearch refuses to start
    file { '/var/run/elasticsearch':
        ensure  => directory,
        owner   => 'elasticsearch',
        group   => 'elasticsearch',
        mode    => '0755',
        require => Package['elasticsearch'],
    }

    file { '/usr/local/bin/mwv-elasticsearch-plugin':
        source => 'puppet:///modules/elasticsearch/mwv-elasticsearch-plugin',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    service { 'elasticsearch':
        ensure  => running,
        enable  => true,
        require => [
            Package['elasticsearch'],
            Package['openjdk-8-jre-headless'],
        ]
    }

    file { '/etc/default/elasticsearch':
        source  => 'puppet:///modules/elasticsearch/defaults',
        require => Package['elasticsearch'],
        notify  => Service['elasticsearch'],
    }

    file { '/etc/elasticsearch/elasticsearch.yml':
        source  => 'puppet:///modules/elasticsearch/elasticsearch.yml',
        require => Package['elasticsearch'],
        notify  => Service['elasticsearch'],
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    file { '/etc/elasticsearch/jvm.options':
        source  => 'puppet:///modules/elasticsearch/jvm.options',
        require => Package['elasticsearch'],
        notify  => Service['elasticsearch'],
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    file { '/etc/elasticsearch/log4j2.properties':
        source  => 'puppet:///modules/elasticsearch/log4j2.properties',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['elasticsearch'],
    }

    file { '/etc/logrotate.d/elasticsearch':
        source => 'puppet:///modules/elasticsearch/logrotate',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    # The logrotate above works on size, rather than daily.  For this to work
    # reasonably well logrotate needs to run multiple times per day
    file { '/etc/cron.hourly':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }
    file { '/etc/cron.hourly/logrotate':
        ensure  => 'link',
        target  => '/etc/cron.daily/logrotate',
        require => File['/etc/cron.hourly'],
    }
}

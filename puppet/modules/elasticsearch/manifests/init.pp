# == Class: Elasticsearch
#
# Elasticsearch is a powerful open source search and analytics
# engine, much like Solr, but with a more user-friendly inteface.
#
class elasticsearch {
    $version = '2.3.3'

    package { 'elasticsearch':
        ensure => $version
    }

    require_package('openjdk-7-jre-headless')

    file { '/var/run/elasticsearch/':
        # Temporary and poor work around for
        # https://github.com/elastic/elasticsearch/issues/11594
        ensure => 'directory'
    }

    service { 'elasticsearch':
        ensure  => running,
        enable  => true,
        require => [
            Package['elasticsearch', 'openjdk-7-jre-headless'],
            File['/var/run/elasticsearch/'],
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
    }

    file { '/etc/elasticsearch/logging.yml':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        content => template('elasticsearch/logging.yml.erb'),
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
    file { '/etc/cron.hourly/logrotate':
        ensure => 'link',
        target => '/etc/cron.daily/logrotate',
    }
}

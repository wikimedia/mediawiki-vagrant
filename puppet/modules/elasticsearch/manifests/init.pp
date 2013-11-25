# == Class: Elasticsearch
#
# Elasticsearch is a powerful open source search and analytics
# engine, much like Solr, but with a more user-friendly inteface.
#
class elasticsearch {
    package { 'elasticsearch':
        ensure => present,
    }

    package { 'openjdk-7-jre-headless':
        ensure => present,
    }

    service { 'elasticsearch':
        enable  => true,
        ensure  => running,
        require => Package['elasticsearch', 'openjdk-7-jre-headless'],
    }
}

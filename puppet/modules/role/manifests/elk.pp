# == Class: role::elk
#
# Provision an ELK stack (ElasticSearch, Logstash, Kibana). Configures
# MediaWiki to send log messages to the ELK cluster using Monolog and Redis.
#
# === Parameters
# [*vhost_name*]
#   vhost_name of Kibana web interface. Default 'logstash.local.wmftest.net'.
#
class role::elk (
    $vhost_name,
){
    require ::role::mediawiki
    require ::role::psr3
    include ::elasticsearch
    include ::redis
    include ::logstash
    include ::logstash::output::elasticsearch
    include ::kibana
    include ::apache::mod::headers
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http

    ## Configure Logstash
    logstash::input::syslog { 'syslog':
        port => 10514,
    }

    logstash::input::gelf { 'gelf':
        port => 12201,
    }

    logstash::input::json { 'json':
        port => 12202,
    }

    logstash::input::udp { 'logback':
        port  => 11514,
        codec => 'json',
    }

    logstash::input::log4j { 'log4j': }

    logstash::conf { 'filter_strip_ansi_color':
        source   => 'puppet:///modules/role/elk/filter-strip-ansi-color.conf',
        priority => 40,
    }

    logstash::plugin { 'logstash-filter-prune':
        ensure => present
    }
    logstash::conf { 'filter_gelf':
        source   => 'puppet:///modules/role/elk/filter-gelf.conf',
        priority => 50,
        require  => Logstash::Plugin['logstash-filter-prune'],
    }

    logstash::plugin { 'logstash-filter-multiline':
        ensure => present
    }
    logstash::plugin { 'logstash-filter-anonymize':
        ensure => present
    }
    logstash::conf { 'filter_syslog':
        source   => 'puppet:///modules/role/elk/filter-syslog.conf',
        priority => 50,
        require  => [
            Logstash::Plugin['logstash-filter-multiline'],
            Logstash::Plugin['logstash-filter-anonymize'],
        ]
    }

    exec { 'Create logstash index template':
        command => template('role/elk/create-logstash-template.erb'),
        unless  => template('role/elk/check-logstash-template.erb'),
        require => Service['elasticsearch'],
        before  => Class['::logstash::output::elasticsearch'],
    }

    ## Configure Kibana
    apache::site { $vhost_name:
        content => template('role/elk/apache.conf.erb'),
    }

    ## Configure MediaWiki
    mediawiki::settings { 'Monolog':
        values  => template('role/elk/monolog.php.erb'),
    }

    ## Configure rsyslog
    rsyslog::conf { 'logstash':
        source   => 'puppet:///modules/role/elk/rsyslog.conf',
        priority => 30,
    }

    mediawiki::import::text { 'VagrantRoleElk':
        content => template('role/elk/VagrantRoleElk.wiki.erb'),
    }
}

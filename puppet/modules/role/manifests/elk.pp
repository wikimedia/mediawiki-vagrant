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

    logstash::conf { 'filter_strip_ansi_color':
        source   => 'puppet:///modules/role/elk/filter-strip-ansi-color.conf',
        priority => 40,
    }

    logstash::conf { 'filter_gelf':
        source   => 'puppet:///modules/role/elk/filter-gelf.conf',
        priority => 50,
    }

    logstash::conf { 'filter_syslog':
        source   => 'puppet:///modules/role/elk/filter-syslog.conf',
        priority => 50,
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

    exec { 'Create kibana index':
        command => template('role/elk/create-kibana-index.erb'),
        unless  => template('role/elk/check-kibana-index.erb'),
        require => Service['elasticsearch'],
    }
    kibana::dashboard { 'default':
        content => template('role/elk/dashboard-default.erb'),
        require => Exec['Create kibana index'],
    }
    kibana::dashboard { 'mediawiki':
        content => template('role/elk/dashboard-mediawiki.erb'),
        require => Exec['Create kibana index'],
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

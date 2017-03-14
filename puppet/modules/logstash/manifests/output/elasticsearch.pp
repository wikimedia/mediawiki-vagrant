# vim:sw=4 ts=4 sts=4 et:

# = Class: logstash::output::elasticsearch
#
# Configure logstash to output to elasticsearch
#
# == Parameters:
# - $host: Elasticsearch server. Default '127.0.0.1'.
# - $flush_size: Maximum number of events to buffer before sending.
#       Default 100.
# - $idle_flush_time: Maxmimum seconds to wait between sends. Default 1.
# - $index: Index to write events to. Default 'logstash-%{+YYYY.MM.dd}'.
# - $port: Elasticsearch server port. Default 9200.
# - $require_tag: Tag to require on events. Default undef.
# - $manage_indices: Whether cron jobs should be installed to manage
#       Elasticsearch indices. Default false.
# - $priority: Configuration loading priority. Default undef.
# - $ensure: Whether the config should exist. Default present.
#
# == Sample usage:
#
#   class { 'logstash::output::elasticsearch':
#       host           => '127.0.0.1',
#       require_tag    => 'es',
#       manage_indices => 'true',
#   }
#
class logstash::output::elasticsearch(
    $ensure              = present,
    $host                = '127.0.0.1',
    $flush_size          = 100,
    $idle_flush_time     = 1,
    $index               = 'logstash-%{+YYYY.MM.dd}',
    $port                = 9200,
    $require_tag         = undef,
    $manage_indices      = false,
    $priority            = undef,
) {
    package { 'elasticsearch-curator':
        ensure   => 'present',
        provider => 'pip',
    }

    logstash::conf{ 'output-elasticsearch':
        ensure   => $ensure,
        content  => template('logstash/output/elasticsearch.erb'),
        priority => $priority,
    }

    $ensure_cron = $manage_indices ? {
        true    => 'present',
        default => 'absent',
    }

    cron { 'logstash_delete_index':
        ensure  => $ensure_cron,
        command => "/usr/local/bin/curator delete --host ${host} --port ${port} --timestring '%Y.%m.%d' --older-than 15",
        user    => 'root',
        hour    => 0,
        minute  => 42,
        require => Package['elasticsearch-curator'],
    }

    cron { 'logstash_optimize_index':
        ensure  => $ensure_cron,
        command => "/usr/local/bin/curator optimize --host ${host} --port ${port} --timestring '%Y.%m.%d' --older-than 2",
        user    => 'root',
        hour    => 1,
        minute  => 5,
        require => Package['elasticsearch-curator'],
    }
}

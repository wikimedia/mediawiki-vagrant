# = Class: logstash
#
# Logstash is a flexible log aggregation framework built on top of
# Elasticsearch, a distributed document store. It lets you configure logging
# pipelines that ingress log data from various sources in a variety of formats.
#
# == Parameters:
# - $heap_memory_mb: amount of memory to allocate to logstash in megabytes.
# - $pipeline_workers: number of worker threads to run to use for
#                      filter/output processing
#
# == Sample usage:
#
#   class { 'logstash':
#       heap_memory_mb => 128,
#       pipeline_workers => 3,
#   }
#
class logstash(
    $heap_memory_mb,
    $pipeline_workers,
) {
    require_package('openjdk-8-jre-headless')

    package { 'logstash':
        ensure  => latest,
        require => Package['openjdk-8-jre-headless'],
    }

    # JRuby waits for enough entropy from /dev/random when starting up. Especially
    # within VM's very little entropy may be available. haveged adds an entropy source
    # to fix this problem.
    package { 'haveged':
        ensure => present,
        before => Service['logstash']
    }
    Package['haveged'] -> Logstash::Plugin <| |>

    file { '/etc/logstash/conf.d':
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/logstash/conf.d',
        require => Package['logstash'],
    }

    file { '/etc/logstash/logstash.yml':
        ensure  => file,
        content => ordered_yaml({
            'path.data'        => '/var/lib/logstash',
            'path.config'      => '/etc/logstash/conf.d',
            'path.logs'        => '/var/log/logstash',
            'pipeline.workers' => $pipeline_workers,
        }),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['logstash'],
        before  => Service['logstash'],
        notify  => Service['logstash'],
    }

    file { '/etc/logstash/jvm.options':
        ensure  => file,
        content => template('logstash/jvm.options.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => Package['logstash'],
        notify  => Service['logstash'],
    }

    service { 'logstash':
        ensure   => running,
        provider => 'systemd',
        enable   => true,
        require  => [
            Package['logstash'],
            File['/etc/logstash/jvm.options']
        ]
    }
}

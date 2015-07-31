# == Class: cassandra
#
# This Puppet class installs and configures Apache Cassandra, a distributed
# NoSQL storage solution.
#
# == Parameters:
#
# [*logdir*]
#   the directory where logs should be stored
# [*max_heap*]
#   the maximum heap size for Cassandra's JVM process
# [*new_size*]
#   the amount of memory to allocate for the heap's young generation
class cassandra(
    $logdir,
    $max_heap,
    $new_size
) {

    # set up the repo pubkey
    file  { '/usr/local/share/datastax-pubkey.asc':
        source => 'puppet:///modules/cassandra/datastax-pubkey.asc',
        owner  => 'root',
        group  => 'root',
        before => File['/etc/apt/sources.list.d/datastax.sources.list'],
        notify => Exec['add_datastax_apt_key'],
    }

    # add the key
    exec { 'add_datastax_apt_key':
        # lint:ignore:80chars
        command     => '/usr/bin/apt-key add /usr/local/share/datastax-pubkey.asc',
        # lint:endignore
        before      => File['/etc/apt/sources.list.d/datastax.sources.list'],
        refreshonly => true,
    }

    # add the cassandra repo list file
    file { '/etc/apt/sources.list.d/datastax.sources.list':
        source => 'puppet:///modules/cassandra/datastax.sources.list',
        owner  => 'root',
        group  => 'root',
        notify => Exec['update_package_index'],
    }

    # copy over cassandra-env.sh with modified JVM memory settings
    file { '/etc/cassandra/cassandra-env.sh':
        content => template('cassandra/cassandra-env.sh.erb'),
        owner   => 'root',
        group   => 'root',
        require => Package['cassandra'],
        notify  => Service['cassandra'],
    }

    # copy over cassandra.yaml
    file { '/etc/cassandra/cassandra.yaml':
        source  => 'puppet:///modules/cassandra/cassandra.yaml',
        owner   => 'root',
        group   => 'root',
        require => Package['cassandra'],
        notify  => Service['cassandra'],
    }

    # copy over logback.xml with modified log dir
    file { '/etc/cassandra/logback.xml':
        content => template('cassandra/logback.xml.erb'),
        owner   => 'root',
        group   => 'root',
        require => Package['cassandra'],
        notify  => Service['cassandra'],
    }

    # make sure the log dir is there and with good chmod
    file { $logdir:
        ensure  => directory,
        mode    => '0777',
        require => Package['cassandra'],
    }

    # we use openjdk as the java distrib
    require_package('openjdk-7-jre-headless')

    package { 'cassandra':
        ensure  => latest,
        require => [
            Package['openjdk-7-jre-headless'],
        ],
    }

    # ensure the service is running
    # note: jobrunner must be started before cassandra, otherwise
    # it cannot allocate enough space for the translation cache
    service { 'cassandra':
        ensure  => running,
        enable  => true,
        require => [
            File[
                '/etc/cassandra/cassandra-env.sh',
                '/etc/cassandra/logback.xml',
                '/etc/cassandra/cassandra.yaml',
                $logdir
            ],
        ],
    }

}


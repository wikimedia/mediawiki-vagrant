# == Class: role::hadoop
# Installs and runs all hadoop services.
class role::hadoop {
    # need java before hadoop is installed
    require packages::java

    $namenode_hosts           = [$::fqdn]

    $hadoop_directory         = '/var/lib/hadoop'
    $hadoop_name_directory    = "${hadoop_directory}/name"
    $hadoop_data_directory    = "${hadoop_directory}/data"

    file { $hadoop_directory:
        ensure => 'directory',
    }
    file { $hadoop_data_directory:
        ensure => 'directory',
    }

    $datanode_mounts = [
      "${hadoop_data_directory}/a",
      "${hadoop_data_directory}/b",
    ]

    # Install Hadoop client and configs
    class { '::cdh4::hadoop':
        namenode_hosts                           => $namenode_hosts,
        datanode_mounts                          => $datanode_mounts,
        dfs_name_dir                             => [$hadoop_name_directory],
        # Turn on Snappy compression by default for maps and final outputs
        mapreduce_intermediate_compression       => true,
        mapreduce_intermediate_compression_codec => 'org.apache.hadoop.io.compress.SnappyCodec',
        mapreduce_output_compression             => true,
        mapreduce_output_compression_codec       => 'org.apache.hadoop.io.compress.SnappyCodec',
        mapreduce_output_compression_type        => BLOCK,
        mapreduce_map_tasks_maximum              => 2,
        mapreduce_reduce_tasks_maximum           => 2,
        # mapreduce.shuffle.port defaults to 8080 apparently.
        # Override this so as not to conflict with apache
        mapreduce_shuffle_port                   => 13562,
        yarn_resourcemanager_scheduler_class     => 'org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler',
    }

    file { "${::cdh4::hadoop::config_directory}/fair-scheduler.xml":
        content => template('hadoop/fair-scheduler.xml.erb'),
        require => Class['cdh4::hadoop'],
    }
    file { "${::cdh4::hadoop::config_directory}/fair-scheduler-allocation.xml":
        content => template('hadoop/fair-scheduler-allocation.xml.erb'),
        require => Class['cdh4::hadoop'],
    }

    # Install and run master and worker classes all on this node.
    # - NameNode
    # - ResourceManager
    # - DataNode
    # - NodeManager
    class { '::cdh4::hadoop::master': }
    class { '::cdh4::hadoop::worker':
        require => Class['::cdh4::hadoop::master'],
    }
}

# == Class: role::hadoop
# Installs and runs all hadoop services.
#
class role::hadoop {
    # Need java before hadoop is installed
    require role::generic

    require_package('openjdk-7-jdk')

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

    # Install Hadoop client and configs.
    class { '::cdh::hadoop':
        cluster_name                             => 'vagrant',
        namenode_hosts                           => $namenode_hosts,
        datanode_mounts                          => $datanode_mounts,
        dfs_name_dir                             => [$hadoop_name_directory],
        # Turn on Snappy compression by default for maps and final outputs.
        mapreduce_intermediate_compression       => true,
        mapreduce_intermediate_compression_codec => 'org.apache.hadoop.io.compress.SnappyCodec',
        mapreduce_output_compression             => true,
        mapreduce_output_compression_codec       => 'org.apache.hadoop.io.compress.SnappyCodec',
        mapreduce_output_compression_type        => BLOCK,
        mapreduce_map_tasks_maximum              => 2,
        mapreduce_reduce_tasks_maximum           => 2,
        # mapreduce.shuffle.port defaults to 8080.
        # Override this so as not to conflict with apache.
        mapreduce_shuffle_port                   => 13562,
        # Use small heapsize for vagrant.
        hadoop_heapsize                          => 64,
        yarn_heapsize                            => 64,
    }

    # Install and run master and worker classes all on this node.
    # - NameNode
    # - ResourceManager
    # - DataNode
    # - NodeManager
    class { '::cdh::hadoop::master': }
    class { '::cdh::hadoop::worker':
        require => Class['::cdh::hadoop::master'],
    }

    class { 'cdh::hadoop::httpfs':
        # Use small heapsize for vagrant.
        heapsize => 64,
        require  => Class['cdh::hadoop::master'],
    }

    # The NameNode and DataNode services return true before
    # HDFS is actually ready.  Some cdh module classes require
    # that HDFS is ready for use.  This command will wait
    # until a write to HDFS completes properly.
    #
    # role::hive and role::oozie add an explicit dependency
    # on this exec for the HDFS commands contained within their
    # cdh module classes.  This ensures that HDFS is totally
    # ready before puppet attempts to set up Hive and Oozie.
    exec { 'wait_for_hdfs':
        command     => '/usr/bin/hdfs dfs -touchz /tmp/puppet_wait_for_hdfs > /dev/null 2>&1 && /usr/bin/hdfs dfs -rm /tmp/puppet_wait_for_hdfs > /dev/null 2>&1',
        tries       => 10,
        try_sleep   => 2,
        subscribe   => [Service['hadoop-hdfs-namenode'], Service['hadoop-hdfs-datanode']],
        refreshonly => true,
    }
}

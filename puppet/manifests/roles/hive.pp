# == Class: role::hive
# Installs and runs hive client, hive metastore and hive server.
class role::hive {
    # We need the root db password defined in the mysql module
    # in order to create the Hive metastore database.
    require role::mysql
    require role::hadoop

    # Need hadoop up and running and configs defined first.
    Class['role::hadoop'] -> Class['role::hive']

    class { '::cdh::hive':
        metastore_host   => $role::hadoop::namenode_hosts[0],
        db_root_password => $::role::mysql::db_pass,
        # $hive_version and $cdh_version are custom facts added by the cdh module.
        auxpath          => 'file:///usr/lib/hive-hcatalog/share/hcatalog/hive-hcatalog-core-0.12.0-cdh5.0.2.jar',
    }

    # Setup Hive server and Metastore
    class { '::cdh::hive::master':
        # Use small heapsize for vagrant.
        heapsize => 64,
    }

    # Make sure HDFS is totally ready before the CDH
    # module tries to create this directory.
    Exec['wait_for_hdfs'] -> Cdh::Hadoop::Directory['/user/hive']

    # Add vagrant user to hive group so that
    # hive-site.xml can be read.
    exec { 'add_vagrant_user_to_hive_group':
        command => '/usr/sbin/usermod --append --groups hive vagrant',
        unless  => '/usr/bin/groups vagrant | grep -q hive',
        require => Class['::cdh::hive'],
    }

    # Add an env variable to keep Hive client heapsize low.
    file { '/etc/profile.d/hive.sh':
        content => "export HADOOP_HEAPSIZE=32\n",
    }
}

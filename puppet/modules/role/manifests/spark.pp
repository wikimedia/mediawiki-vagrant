# == Class role::spark
#
class role::spark {
    require ::role::hadoop

    class { '::cdh::spark': }

    # Make sure HDFS is totally ready before the CDH
    # module tries to create this directory.
    Exec['wait_for_hdfs'] -> Cdh::Hadoop::Directory['/user/spark']
}

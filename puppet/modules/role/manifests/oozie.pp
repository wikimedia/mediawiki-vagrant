# == Class role::oozie
# Install Oozie server and client.
#
class role::oozie {
    require ::role::hadoop
    include ::cdh::oozie
    include ::cdh::oozie::server

    # Make sure HDFS is totally ready before the CDH
    # module tries to create this directory.
    Exec['wait_for_hdfs'] -> Cdh::Hadoop::Directory['/user/oozie']
}

# == Class role::oozie
# Install Oozie server and client.
#
class role::oozie {
    # We need the root db password defined in the mysql module
    # in order to create the oozie database.
    require role::mysql
    require role::hadoop

    class { 'cdh::oozie': }
    class { 'cdh::oozie::server':
        db_root_password => $::role::mysql::db_pass,
        # Use a small heapsize for vagrant.
        heapsize         => 64,
    }

    # Make sure HDFS is totally ready before the CDH
    # module tries to create this directory.
    Exec['wait_for_hdfs'] -> Cdh::Hadoop::Directory['/user/oozie']
}

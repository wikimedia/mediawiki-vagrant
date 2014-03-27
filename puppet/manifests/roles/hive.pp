# == Class: role::hive
# Installs and runs hive client, hive metastore and hive server.
class role::hive {
    # Mediawiki includes the mysql module.
    # We need the root db password defined there
    # in order to create the Hive metastore database.
    require role::mysql
    # Need hadoop up and running and configs defined first.
    Class['role::hadoop'] -> Class['role::hive']

    class { '::cdh4::hive':
        metastore_host   => $role::hadoop::namenode_hosts[0],
        db_root_password => $::role::mysql::db_pass,
    }

    # Setup Hive server and Metastore
    class { '::cdh4::hive::master': }

    # Include hcatalog class so that Hive clients can use
    # ths JsonSerDe from it.  If we expand the usage of HCatalog
    # in the future, this will probably move to its own role.
    class { '::cdh4::hcatalog':
        require => Class['::cdh4::hive'],
    }

    # Add vagrant user to hive group so that
    # hive-site.xml can be read.
    exec { 'add_vagrant_user_to_hive_group':
        command => '/usr/sbin/usermod --append --groups hive vagrant',
        unless  => '/usr/bin/groups vagrant | grep -q hive',
        require => Class['::cdh4::hive'],
    }
}

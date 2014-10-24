# == Class: role::wikimetrics
# Wikimetrics is a Wikimedia Foundation developed tool that provides
# access to the Wikimedia API. It allows users to pull data about a
# group of usernames (called cohorts) to discover retention rates for
# those users, how many characters they have added, how many edits they
# have made, how many pages they have created, etc, all within time
# periods the Wikimetrics user sets.
#
# This role installs and hosts Wikimetrics at http://localhost:5000.
# (both the guest and host)
#
# NOTE!  You will need the wikimetrics git submodule available.
# Run this command on your local machine make sure modules/wikimetrics
# is cloned and up to date:
#
#    git submodule update --init
#
class role::wikimetrics {
    require ::role::mediawiki
    require ::role::centralauth
    require ::mysql::packages

    require_package('python-nose')

    $wikimetrics_path = '/vagrant/wikimetrics'

    # Should Wikimetrics run under Apache or using the development server?
    # Legal values are 'daemon' and 'apache'.
    $web_server_mode = 'daemon'

    # Make wikimetrics group 'www-data' if running in apache mode.
    # This allows for apache to write files to wikimetrics var directories
    $wikimetrics_group = $web_server_mode ? {
        'apache' => 'www-data',
        default  => 'wikimetrics',
    }

    class { '::wikimetrics':
        path                  => $wikimetrics_path,
        group                 => $wikimetrics_group,
        # Use the role::mediawiki MySQL database for
        # wikimetrics editor cohort analysis
        db_user_mediawiki     => $::mediawiki::db_user,
        db_pass_mediawiki     => $::mediawiki::db_pass,
        db_name_mediawiki     => $::mediawiki::db_name,
        db_host_mediawiki     => 'localhost',
        # Use the role::centralauth MySQL database for
        # wikimetrics cohort user expansion
        db_user_centralauth   => $::mediawiki::db_user,
        db_pass_centralauth   => $::mediawiki::db_pass,
        db_name_centralauth   => $::role::centralauth::shared_db,
        db_host_centralauth   => 'localhost',
        # clone wikimetrics as vagrant user
        # so that it works properly in the shared
        # /vagrant directory
        repository_owner      => 'vagrant',
        # wikimetrics runs on the LabsDB usually,
        # where this table is called 'revision_userindex'.
        # The mediawiki database usually calls this 'revision'.
        revision_tablename    => 'revision',
        archive_tablename     => 'archive',
        # Since we are using the /vagrant shared directory for configs,
        # make sure puppet doesn't try to change the ownership every time
        # it runs.
        config_file_owner     => 'vagrant',
        config_file_group     => 'www-data',
        # make upstart managed services start after
        # /vagrant shared directory is mounted.
        service_start_on      => 'vagrant-mounted',
    }

    # Run the wikimetrics/scripts/install script
    # in order to pip install proper dependencies.
    # Note:  This is not in the wikimetrics puppet module
    # because it is an improper way to do things in
    # WMF production.
    exec { 'install_wikimetrics_dependencies':
        command => "${wikimetrics_path}/scripts/install ${wikimetrics_path}",
        creates => '/usr/local/bin/wikimetrics',
        path    => '/usr/local/bin:/usr/bin:/bin',
        user    => 'root',
        require => Class['::wikimetrics'],
    }

    class { '::wikimetrics::database':
        db_root_pass     => $::mysql::root_password,
        wikimetrics_path => $wikimetrics_path,
        require          => Exec['install_wikimetrics_dependencies'],
    }

    class { '::wikimetrics::queue':
        require => [
            Exec['install_wikimetrics_dependencies'],
            # role::mediawiki installs redis, and queue needs this.
            Class['role::mediawiki'],
        ]
    }

    class { '::wikimetrics::scheduler':
        require => Exec['install_wikimetrics_dependencies'],
    }

    # make sure wsgi is included in case we are running in apache WSGI mode.
    include ::apache::mod::wsgi
    class { 'wikimetrics::web':
        mode    => $web_server_mode,
        require => Exec['install_wikimetrics_dependencies'],
    }

    vagrant::settings { 'wikimetrics':
      # Wikimetrics web frontend is on port 5000
      forward_ports => { 5000  => 5000 },
      # For running tests on 2014-08-21's master, ~2.1 GB RAM are needed
      ram           => 3072,
    }
}

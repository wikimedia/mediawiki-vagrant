# == Class: xhprof
#
# This Puppet class configures XHProf, a function-level hierarchical
# profiler for PHP with a simple HTML based navigational interface.
#
# === Parameters
#
# [*profile_storage_dir*]
#   Path where profiles should be stored. Default: '/vagrant/profiles'.
#
class xhprofgui (
    $profile_storage_dir = '/vagrant/profiles'
) {

    git::install { 'phacility/xhprof':
        directory => "/srv/xhprof",
        remote => "https://github.com/phacility/xhprof",
        commit => "HEAD",
    }

    php::ini { 'xhprofgui':
        settings => {
            # Not used by the extension directly, used by the
            # XHProf_Runs utility class
            'xhprof.output_dir' => $profile_storage_dir,
        }
    }

    # Directory used, by default, to store profile runs
    file { $profile_storage_dir:
        ensure => directory,
        owner  => $::share_owner,
        group  => $::share_group,
        mode   => '0775',
    }

    # Enable xhprof viewer on /xhprof directory of devwiki
    apache::conf { 'xhprof':
        ensure  => present,
        source  => 'puppet:///modules/xhprofgui/xhprof-apache-config',
        require => Php::Ini['xhprofgui'],
    }
}

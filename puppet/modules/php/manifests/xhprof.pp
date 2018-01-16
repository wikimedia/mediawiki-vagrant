# == Class: php::xhprof
#
# Profiler for PHP
#
# === Parameters
#
# [*profile_storage_dir*]
#   Path where profiles should be stored.
class php::xhprof (
    $profile_storage_dir,
) {

    package { 'php-tideways':
        ensure  => present,
    }

    php::ini { 'xhprof_enable':
        settings => {
            # Not used by the extension directly, used by the
            # XHProf_Runs utility class
            'xhprof.output_dir' => $profile_storage_dir,
        },
        require  => Package['php-tideways'],
    }

    # Directory used, by default, to store profile runs
    file { $profile_storage_dir:
        ensure => directory,
        owner  => $::share_owner,
        group  => $::share_group,
        mode   => '0775',
    }
}

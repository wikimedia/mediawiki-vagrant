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

    package { 'php5-xhprof':
        ensure  => present,
    }

    php::ini { 'xhprof_enable':
        settings => {
            # We don't use php5enmod on the packaged ini because the
            # default config triggers a deprecation warning due to a #
            # comment.
            'extension'         => 'xhprof.so',
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
}

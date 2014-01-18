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
class xhprof (
    $profile_storage_dir = '/vagrant/profiles'
) {

    $xhprof_version      = '0.9.4'
    $installed_module    = '/usr/lib/php5/20090626/xhprof.so'

    exec { 'download xhprof':
        cwd     => '/tmp',
        creates => $installed_module,
        command => "wget http://pecl.php.net/get/xhprof-${xhprof_version}.tgz",
    }

    exec { 'extract xhprof':
        cwd     => '/tmp',
        command => "tar -xzf xhprof-${xhprof_version}.tgz",
        creates => $installed_module,
        require => Exec['download xhprof'],
    }

    exec { 'install xhprof':
        cwd     => "/tmp/xhprof-${xhprof_version}/extension",
        command => 'phpize && ./configure && make && make install',
        creates => $installed_module,
        require => [ Exec['extract xhprof'], Package['php5-dev'] ],
    }

    exec { 'install xhprof assets':
        cwd     => "/tmp/xhprof-${xhprof_version}",
        command => "cp -rf /tmp/xhprof-${xhprof_version}/xhprof_html /tmp/xhprof-${xhprof_version}/xhprof_lib /usr/share/php",
        creates => '/usr/share/php/xhprof_html',
        # php-pear ensures existance of /usr/share/php, better way?
        require => [ Exec['install xhprof'], Package['php-pear'] ],
    }

    php::ini { 'xhprof':
        require  => Exec['install xhprof'],
        settings => {
            'extension'         => 'xhprof.so',
            # Not used by the extension directly, used by the
            # XHProf_Runs utility class
            'xhprof.output_dir' => $profile_storage_dir,
        }
    }

    # Directory used, by default, to store profile runs
    file { $profile_storage_dir:
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }

    # Enable xhprof viewer on /xhprof directory of devwiki
    apache::conf { 'xhprof':
        ensure  => present,
        site    => $role::mediawiki::wiki_name,
        source  => 'puppet:///modules/xhprof/xhprof-apache-config',
        require => Php::Ini['xhprof'],
    }
}

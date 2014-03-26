# vim:set sw=4 ts=4 sts=4 et:

# == Class vagrant
#
#
# === Parameters
#
# [*settings_dir*]
#   Directory to place vagrant settings files in. This must match
#   configuration in the Vagrantfile itself for the files to be found at
#   Vagrant runtime. Default is '/vagrant/vagrant.d'.
#
class vagrant(
    $settings_dir = '/vagrant/vagrant.d',
){

    File {
        group   => 'www-data',
        owner   => 'vagrant',
    }

    file { $settings_dir:
        ensure  => directory,
        purge   => true,
        recurse => true,
    }

    file { "${settings_dir}/README":
        ensure  => present,
        require => File[$settings_dir],
        source  => 'puppet:///modules/vagrant/README',
    }
}

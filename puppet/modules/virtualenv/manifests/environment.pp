# == Class virtualenv
# Helper class to install python packages via virtualenv.
# Will create a virtualenv directory with the given packages.
#
# This is a nasty hack which does not use package providers
# as puppet does not suppose using those with virtualenv:
# https://tickets.puppetlabs.com/browse/PUP-1062
#
# === Parameters
#
# [*ensure*]
#   'present' to create the environment, 'absent' to delete
#   it (along with all contents, whether puppet-managed or not)
#
# [*dir*]
#   The directory where the virtual environment should be.
#   Will be created if it does not exist.
#
# [*packages*]
#   An array of pip packages to install during virtualenv creation.
#   Default: undef
#   NOTE: You can also install packages into this virtualenv after
#   creation using the virtualenv::package define.
#
# [*owner*]
#   User owner of the environment directory and created files.
#
# [*group*]
#   Group owner of the environment directory and created files.
#
# [*timeout*]
#   Timeout for the command creating the environment.
#
define virtualenv::environment (
    $packages  = undef,
    $dir       = $title,
    $ensure    = 'present',
    $owner     = 'root',
    $group     = 'root',
    $timeout   = 300,
) {
    require ::virtualenv

    if $ensure == 'present' {
        file { $dir:
            ensure => directory,
            owner  => $owner,
            group  => $group,
        }

        $command = $packages ? {
            undef   => '/usr/local/bin/virtualenv .',
            default => inline_template("./bin/pip install '<%= @packages.join(\"' '\") %>'")
        }

        exec { "virtualenv-${dir}":
            command => template('virtualenv/create-virtualenv.sh.erb'),
            cwd     => $dir,
            creates => "${dir}/lib",
            user    => $owner,
            group   => $group,
            require => File[$dir],
            timeout => $timeout,
        }
    } elsif $ensure == 'absent' {
        file { $dir:
            ensure  => absent,
            force   => true,
            recurse => true,
            purge   => true,
        }
    }
}



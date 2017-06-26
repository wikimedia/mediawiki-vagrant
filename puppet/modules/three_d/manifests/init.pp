# == Class: three_d
#
# This Puppet class installs and configures the binaries needed by the 3d extensions.
#
# === Parameters
#
# [*three_d_2png_dir*]
#   Path where 3d2png should be installed (example: '/var/3d2png').
#
class three_d (
    $three_d_2png_dir,
) {
    require_package('pkg-config')
    require_package('libcairo2-dev')
    require_package('libjpeg-dev')
    require_package('libxi-dev')
    require_package('libglu1-mesa-dev')
    require_package('libglew-dev')
    require_package('libgif-dev')
    require_package('libgl1-mesa-dri')

    file { $three_d_2png_dir:
        ensure => directory,
        owner  => 'vagrant',
    }

    git::clone { '3d2png':
        directory => $three_d_2png_dir,
        remote    => 'https://gerrit.wikimedia.org/r/p/3d2png',
        owner     => 'vagrant',
    }

    # the gl module needs prebuild installed for the --no-bin-links option
    exec { '3d2png_prebuild':
        command => '/usr/bin/npm install prebuild',
        cwd     => $three_d_2png_dir,
        user    => 'vagrant',
        creates => "${three_d_2png_dir}/node_modules/prebuild",
        require => [
            Git::Clone['3d2png'],
        ],
    }

    # cannot use npm::install because by that point node_modules already exists
    exec { '3d2png_npm_install':
        command     => '/usr/bin/npm install --no-bin-links',
        cwd         => $three_d_2png_dir,
        user        => 'vagrant',
        environment => [
            "NPM_CONFIG_CACHE=${::npm::cache_dir}",
            'NPM_CONFIG_GLOBAL=false',
            'LINK=g++',
            'HOME=/home/vagrant',
        ],
        creates     => "${three_d_2png_dir}/node_modules/yargs",
        require     => [
            Exec['3d2png_prebuild'],
        ],
    }
}

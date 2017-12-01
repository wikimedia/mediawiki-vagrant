# == Class: role::huggle
# Provision build environment for Huggle.
#
# Clones the Huggle git repository and installs libraries needed for
# development and testing. See
# http://dev.wiki.local.wmftest.net:8080/wiki/VagrantRoleHuggle for details.
class role::huggle {
    include ::mwv

    require_package(
        'libqt4-dev',
        'libqt4-webkit',
        'libqt4-network',
        'qt4-qmake',
        'libqtwebkit-dev',
        'libqt4-dev-bin',
        'qt4-dev-tools',
    )

    git::clone { 'huggle':
        directory => "${::mwv::services_dir}/huggle",
        remote    => 'https://github.com/huggle/huggle3-qt-lx.git',
    }

    # Add some documentation for developers
    mediawiki::import::text { 'VagrantRoleHuggle':
        content => template('role/huggle/VagrantRoleHuggle.wiki.erb'),
    }
}

# vim:set sw=4 ts=4 sts=4 et:

# == Class: arcanist
#
# This class clones arcanist and libphutil for developer use
#
# [*deploy_dir*]
#   The system path to checkout arcanist & libphutil to. (example: '/vagrant/phab')
#
class arcanist(
    $deploy_dir,
){
    include ::php

    git::clone { 'https://github.com/phacility/libphutil':
        directory => "${deploy_dir}/libphutil",
        remote    => 'https://github.com/phacility/libphutil',
    }

    git::clone { 'https://github.com/phacility/arcanist':
        directory => "${deploy_dir}/arcanist",
        remote    => 'https://github.com/phacility/arcanist',
    }

    env::profile_script { 'add arcanist bin to path':
        content => "export PATH=\$PATH:${deploy_dir}/arcanist/bin",
    }

    service::gitupdate { 'libphutil':
        dir => "${deploy_dir}/libphutil",
    }

    service::gitupdate { 'arcanist':
        dir => "${deploy_dir}/arcanist",
    }

}

# vim:set sw=4 ts=4 sts=4 et:

# == Class: arcanist
#
# This class clones arcanist for developer use
#
# [*deploy_dir*]
#   The system path to checkout arcanist to (example: '/vagrant/phab').
#
class arcanist(
    $deploy_dir,
){
    include ::php

    git::clone { 'arcanist':
        directory => "${deploy_dir}/arcanist",
        branch    => 'wmf/stable',
        remote    => 'https://phabricator.wikimedia.org/diffusion/ARC/arcanist.git',
    }

    env::profile_script { 'add arcanist bin to path':
        content => "export PATH=\$PATH:${deploy_dir}/arcanist/bin",
    }

    service::gitupdate { 'arcanist':
        dir => "${deploy_dir}/arcanist",
    }

}

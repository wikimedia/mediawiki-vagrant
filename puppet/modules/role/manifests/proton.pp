# == Class: role::proton
# Installs the Proton[1] PDF renderer
#
# [1]: https://www.mediawiki.org/wiki/Proton
#
class role::proton(
    $vhost_name,
) {
    require ::proton
    include ::role::restbase

    apache::reverse_proxy { 'proton':
      port => $::proton::port,
    }

    mediawiki::import::text { 'VagrantRoleProton':
        content => template('role/proton/VagrantRoleProton.wiki.erb'),
    }
}

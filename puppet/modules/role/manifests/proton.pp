# == Class: role::proton
# Installs the Proton[https://www.mediawiki.org/wiki/Proton]
# PDF renderer
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

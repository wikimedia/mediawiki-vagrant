# == Class: role::ores_service
# This role installs the [ORES][https://ores.wikimedia.org/] service.
#
class role::ores_service {
    include ::ores

    $ores_hostname = $::ores::vhost_name
    mediawiki::import::text { 'VagrantRoleOresService':
        content => template('role/ores_service/VagrantRoleOresService.wiki.erb'),
    }
}

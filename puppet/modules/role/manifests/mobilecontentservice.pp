# == Class: role::mobilecontentservice
# This role installs the mobile content service.
#
# === Parameters
#
# [*vhost_name*]
#   A virtual domain name for convenient access to the service.
#   See apache::port_alias. Expected to be set up already.
#
class role::mobilecontentservice(
    $vhost_name,
) {
    include ::role::restbase
    include ::role::mobilefrontend
    include ::mobilecontentservice

    mediawiki::import::text { 'VagrantRoleMobileContentService':
        content => template('role/mobilecontentservice/VagrantRoleMobileContentService.wiki.erb'),
    }
}

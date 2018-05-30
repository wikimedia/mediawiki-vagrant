# == Class: role::citoid
# Provisions Citoid, a MediaWiki service for converting URLs to
# citations. To expose it to users, enable the visualeditor role.
class role::citoid(
    $url,
) {
    include ::citoid

    mediawiki::import::text { 'VagrantRoleCitoid':
        content => template('role/citoid/VagrantRoleCitoid.wiki.erb'),
    }
}

# == Class: role::parsoid
# Configures Parsoid, a wikitext parsing service
class role::parsoid(
    $public_url,
) {
    include ::parsoid

    apache::reverse_proxy { 'parsoid':
        port => $::parsoid::port,
    }

    # register the PHP Virtual REST Service connector
    mediawiki::settings { 'parsoid-vrs':
        values   => template('role/parsoid/vrs.php.erb'),
        priority => 4,
    }

    mediawiki::import::text { 'VagrantRoleParsoid':
        content => template('role/parsoid/VagrantRoleParsoid.wiki.erb'),
    }
}

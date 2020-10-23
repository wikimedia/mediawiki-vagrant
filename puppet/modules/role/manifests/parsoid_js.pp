# == Class: role::parsoid_js
# Configures Parsoid/JS, a wikitext parsing service
class role::parsoid_js(
    $public_url,
) {
    include ::parsoid

    apache::reverse_proxy { 'parsoid':
        port => $::parsoid::port,
    }

    # register the PHP Virtual REST Service connector
    mediawiki::settings { 'parsoid_js-vrs':
        values   => template('role/parsoid_js/vrs.php.erb'),
        priority => 4,
    }

    mediawiki::import::text { 'VagrantRoleParsoidJs':
        content => template('role/parsoid_js/VagrantRoleParsoidJs.wiki.erb'),
    }
}

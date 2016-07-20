# == Class: role::parsoid
# Configures Parsoid, a wikitext parsing service
class role::parsoid {
    include ::parsoid

    # register the PHP Virtual REST Service connector
    mediawiki::settings { 'parsoid-vrs':
        values   => template('role/parsoid/vrs.php.erb'),
        priority => 4,
    }

}

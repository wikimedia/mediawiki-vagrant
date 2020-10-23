# == Class: role::parsoid
# Configures Parsoid/PHP, a wikitext parsing service.
class role::parsoid {
    include ::mediawiki

    $parsoid_dir = "${::mediawiki::dir}/vendor/wikimedia/parsoid";

    # register the PHP Virtual REST Service connector
    mediawiki::settings { 'parsoid-vrs':
        values   => template('role/parsoid/vrs.php.erb'),
        priority => 4,
    }

    mediawiki::settings { 'parsoid-extension':
        values => "wfLoadExtension( 'Parsoid', '${parsoid_dir}/extension.json' );",
    }

    # Make the Parsoid directory into a proper checkout for developer convenience
    php::composer::prefer_source { 'parsoid':
        app_dir    => $::mediawiki::dir,
        library    => 'wikimedia/parsoid',
        git_remote => 'https://gerrit.wikimedia.org/r/mediawiki/services/parsoid',
    }

    mediawiki::import::text { 'VagrantRoleParsoid':
        content => template('role/parsoid/VagrantRoleParsoid.wiki.erb'),
    }
}

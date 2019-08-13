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

    # As a temporary hack, register Parsoid as an extension
    # (can't use mediawiki::extension as it gets installed as a service
    # and the git declarations would conflict).
    mediawiki::settings { 'parsoid-extension':
        values => "wfLoadExtension( 'Parsoid', '${::service::root_dir}/parsoid/extension.json' );",
    }
    php::composer::install{ "${::service::root_dir}/parsoid":
        prefer  => 'source',
        # This is defined in ::Parsoid -> Service::Node['parsoid'].
        # Better than depending on the entire service definition
        # which includes launching the daemon, running update scripts
        # etc. and would probably introduce a cycle somewhere.
        require => Git::Clone['parsoid'],
    }

    mediawiki::import::text { 'VagrantRoleParsoid':
        content => template('role/parsoid/VagrantRoleParsoid.wiki.erb'),
    }
}

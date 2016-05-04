# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include ::role::antispam
    include ::role::checkuser
    include ::role::eventlogging
    include ::role::externalstore
    include ::role::memcached
    include ::role::parserfunctions
    include ::role::parsoid
    include ::role::echo
    include ::role::betafeatures
    include ::role::varnish

    mediawiki::extension { 'Flow':
        needs_update  => true,
        settings      => template('role/flow/conf.php.erb'),
        priority      => $::LOAD_LAST,  # load *after* Echo
        browser_tests => '.',
    }

    mediawiki::group { 'flow-creator':
      wiki              => $::mediawiki::wiki_name,
      group_name        => 'flow-creator',
      grant_permissions => [
        'flow-create-board',
      ],
    }

    $privileged_username = 'Selenium Flow user'
    mediawiki::user { $privileged_username:
        password => $::mediawiki::admin_pass,
        wiki     => $::mediawiki::db_name,
        groups   => [
            'sysop',
            'suppress',
            'flow-creator',
        ],
    }

    $regular_username = 'Selenium Flow user 2'
    mediawiki::user { $regular_username:
        password => $::mediawiki::admin_pass,
        wiki     => $::mediawiki::db_name,
    }

    role::centralauth::migrate_user { [ $privileged_username, $regular_username ]: }

    file { '/etc/logrotate.d/mediawiki_Flow':
        source => 'puppet:///modules/role/flow/logrotate.d-mediawiki-Flow',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }
}

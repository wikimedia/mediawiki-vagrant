# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include ::role::memcached
    include ::role::parserfunctions
    include ::role::parsoid
    include ::role::echo

    mediawiki::extension { 'Flow':
        needs_update  => true,
        settings      => template('role/flow/conf.php.erb'),
        composer      => true,
        priority      => $::load_last,  # load *after* Echo
        browser_tests => '.',
    }

    mediawiki::group { 'flow-creator':
      wiki              => $::mediawiki::wiki_name,
      group_name        => 'flow-creator',
      grant_permissions => [
        'flow-create-board',
      ],
    }

    file { '/etc/logrotate.d/mediawiki_Flow':
        source => 'puppet:///modules/role/flow/logrotate.d-mediawiki-Flow',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }
}

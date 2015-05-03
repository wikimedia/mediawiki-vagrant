# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include ::role::eventlogging
    include ::role::parsoid
    include ::role::echo

    mediawiki::extension { 'Flow':
        needs_update  => true,
        settings      => template('role/flow/conf.php.erb'),
        priority      => $::LOAD_LAST,  # load *after* Echo
        browser_tests => '.',
    }

    file { '/etc/logrotate.d/mediawiki_Flow':
        source  => 'puppet:///modules/role/flow/logrotate.d-mediawiki-Flow',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }
}

# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include role::mediawiki
    include role::parsoid

    mediawiki::extension { 'Flow':
        needs_update => true,
        settings     => template('flow-config.php.erb'),
    }
}

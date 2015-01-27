# == Class: role::flow
# Configures Flow, a MediaWiki discussion system.
class role::flow {
    include ::role::parsoid
    include ::role::mantle
    include ::role::echo

    mediawiki::extension { 'Flow':
        needs_update => true,
        settings     => template('role/flow-config.php.erb'),
        priority     => $::LOAD_LAST,  # load *after* Mantle and Echo
    }
}

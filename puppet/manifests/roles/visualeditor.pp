# == Class: role::visualeditor
# Provisions the VisualEditor extension, backed by a local Parsoid
# instance.
class role::visualeditor {
    include role::cite
    include role::mediawiki
    include role::parserfunctions
    include role::parsoid
    include role::scribunto
    include role::templatedata

    mediawiki::extension { 'VisualEditor':
        settings      => template('ve-config.php.erb'),
        browser_tests => 'modules/ve-mw/tests/browser',
    }
}

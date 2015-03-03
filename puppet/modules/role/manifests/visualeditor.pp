# == Class: role::visualeditor
# Provisions the VisualEditor extension, backed by a local Parsoid
# instance.
class role::visualeditor {
    include ::role::cite
    include ::role::parserfunctions
    include ::role::parsoid
    include ::role::scribunto
    include ::role::templatedata
    include ::role::uls

    mediawiki::extension { 'VisualEditor':
        settings      => template('role/ve-config.php.erb'),
        browser_tests => 'modules/ve-mw/tests/browser',
        priority      => $::LOAD_EARLY,
    }
}

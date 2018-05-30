# == Class: role::visualeditor
# Provisions the VisualEditor extension, backed by a local RESTBase service
# and Parsoid instance.
#
# Note: this role is not multiwiki aware and will only work on the default
# wiki.
class role::visualeditor {
    require ::role::mediawiki
    include ::role::cite
    include ::role::citoid
    include ::role::parserfunctions
    include ::role::restbase
    include ::role::scribunto
    include ::role::templatedata
    include ::role::uls

    mediawiki::extension { 'VisualEditor':
        settings      => template('role/visualeditor/conf.php.erb'),
        browser_tests => 'modules/ve-mw/tests/browser',
        priority      => $::load_early,
        wiki          => $::mediawiki::wiki_name,
    }


    mediawiki::extension { 'Citoid':
        settings => {
            wgCitoidServiceUrl => $::role::citoid::url,
        },
        wiki     => $::mediawiki::wiki_name,
    }
}

# == Class: role::visualeditor
# Provisions the VisualEditor extension with a minimal setup (use
# visualeditor_wikimedia for an extended one).
#
class role::visualeditor {
    require ::role::mediawiki

    mediawiki::extension { 'VisualEditor':
        settings => template('role/visualeditor/conf.php.erb'),
        priority => $::load_early,
    }
}

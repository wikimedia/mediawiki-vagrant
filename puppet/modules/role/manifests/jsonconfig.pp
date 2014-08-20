# == Class: role::jsonconfig
# The extension that allows other extensions to store JSON text in wiki pages
# See http://www.mediawiki.org/wiki/Extension:JsonConfig
class role::jsonconfig {
    include ::role::codeeditor   # optional - looks better for editing

    mediawiki::extension { 'JsonConfig':
        priority => $::LOAD_EARLY, # ensure that extensions that use JsonConfig will load later
    }
}

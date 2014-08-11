# == Class: role::wikieditor
# Configures WikiEditor, an extension which enable an extendable editing
# toolbar and interface
class role::wikieditor {
    mediawiki::extension { 'WikiEditor':
        settings => [
            '$wgDefaultUserOptions["usebetatoolbar"] = 1',
            '$wgDefaultUserOptions["usebetatoolbar-cgd"] = 1',
        ],
    }
}

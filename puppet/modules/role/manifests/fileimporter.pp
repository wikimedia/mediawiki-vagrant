# == Class: role::fileimporter
class role::fileimporter {
    include ::role::wikieditor

    mediawiki::extension { 'FileImporter':
    }
}

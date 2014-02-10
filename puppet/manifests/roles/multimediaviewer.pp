# == Class: role::multimediaviewer
# This role provisions the MultimediaViewer extension,
# which shows images and their metadata in a lightbox
# when the user clicks on the thumbnails.
class role::multimediaviewer {
    include role::mediawiki
    include role::multimedia

    include packages::jsduck

    mediawiki::extension { 'MultimediaViewer':
        require => Package['jsduck'],
    }
}

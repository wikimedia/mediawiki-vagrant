# == Class: role::multimediaviewer
# This role provisions the MultimediaViewer extension,
# which shows images and their metadata in a lightbox
# when the user clicks on the thumbnails.
class role::multimediaviewer {
    include role::mediawiki
    include role::multimedia

    mediawiki::extension { 'MultimediaViewer':
    }
}

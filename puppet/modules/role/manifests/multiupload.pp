# == Class: role::multiupload
# MultiUpload is extension for uploading much files in same time.
#
class role::multiupload {
    include ::role::mediawiki
    mediawiki::extension { 'MultiUpload': }
}

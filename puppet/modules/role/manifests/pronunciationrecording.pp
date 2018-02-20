# == Class: role::pronunciationrecording
# MultiUpload is extension which allow users to record pronunciations for Wiktionary.
#
class role::pronunciationrecording {
    include ::role::mediawiki
    mediawiki::extension { 'PronunciationRecording': }
}
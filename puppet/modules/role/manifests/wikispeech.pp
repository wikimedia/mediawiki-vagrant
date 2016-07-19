# == Class: role::wikispeech
# This role sets up the Wikispeech extension for MediaWiki.
#
class role::wikispeech {
    mediawiki::extension { 'Wikispeech': }
}

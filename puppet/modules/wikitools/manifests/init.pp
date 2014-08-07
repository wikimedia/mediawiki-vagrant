# == Class: wikitools
#
# Provisions Wikitools, a Python toolkit for MediaWiki.
#
class wikitools {
    package { 'wikitools':
        ensure   => '1.1',
        provider => 'pip',
    }
}

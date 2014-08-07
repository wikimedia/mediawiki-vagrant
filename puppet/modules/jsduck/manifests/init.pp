# == Class: jsduck
#
# This role provisions JSDuck, a Javascript documentation tool
# commonly used in MediaWiki code.
#
class jsduck {
    package { 'jsduck':
        ensure   => '4.10.4',
        provider => 'gem',
    }
}

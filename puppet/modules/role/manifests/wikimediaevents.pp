# == Class: role::wikimediaevents
# Configures WikimediaEvents, a MediaWiki extension that uses
# EventLogging to log certain events.
class role::wikimediaevents {
    include role::mediawiki
    include role::eventlogging

    mediawiki::extension { 'WikimediaEvents': }
}

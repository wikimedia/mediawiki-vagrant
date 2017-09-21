# == Class: role::wikimediaevents
# Configures WikimediaEvents, a MediaWiki extension that uses
# EventLogging to log certain events.
class role::wikimediaevents {
    include ::role::eventlogging
    include ::role::xanalytics

    mediawiki::extension { 'WikimediaEvents':
        settings => {
            'wgWMEStatsdBaseUri' => '/beacon/statsv',
        }
    }
}

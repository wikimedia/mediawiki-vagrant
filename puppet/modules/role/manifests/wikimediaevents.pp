# == Class: role::wikimediaevents
# Configures WikimediaEvents, a MediaWiki extension that uses
# EventLogging to log certain events.
class role::wikimediaevents {
    include ::role::eventbus
    include ::role::eventlogging
    include ::role::xanalytics

    mediawiki::extension { 'WikimediaEvents':
        settings => {
            'wgWMEStatsdBaseUri' => '/beacon/statsv',
        }
    }

    mediawiki::extension { 'TestKitchen':
        settings => {
            'wgTestKitchenInstrumentConfiguratorBaseUrl' => 'https://test-kitchen.wikimedia.org',
            'wgTestKitchenEnableExperiments' => true,
        }
    }
}

# == Class role::eventbus
#
# Sets up eventlogging-service-eventbus using eventbus-topics.yaml
# topic -> schema mapping, and mediawiki/event-schemas repository.
# This accepts HTTP POSTs on port 8085 and produceds valid events to
# Kafka and to logs/eventbus.log.
#
class role::eventbus {
    require ::kafka
    require ::eventlogging
    require ::eventschemas
    include ::changeprop

    # eventgate is intended to replace eventlogging-serivce-eventbus.
    # Run them side by side for now.
    require ::eventgate

    $eventbus_url = 'http://localhost:8085/v1/events'
    $eventgate_url = "http://localhost:${::eventgate::port}/v1/events"
    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => {
            'wgEventServices' => {
                'eventbus'  => {
                    'url' => $eventbus_url,
                },
                'eventgate' => {
                    'url' => $eventgate_url,
                },
            },
            # Configure EventBusRCFeedEngine to produce
            # to datacenter1.mediawiki.recentchange topic.
            'wgRCFeeds'       => {
                'eventbus' => {
                    'class'            => 'EventBusRCFeedEngine',
                    'formatter'        => 'EventBusRCFeedFormatter',
                    'eventServiceName' => 'eventbus',
                },
            },
        },
    }

    # TODO: This will be deprecated in favor of eventgate service
    #       once schemas and events are compatible.
    $outputs = [
        # Output to Kafka.  All messages will produced to topics prefixed
        # with a datacenter name.
        # In mediawiki-vagrant this defaults to 'datacenter1'.
        'kafka:///localhost:9092?async=False&topic=datacenter1.{meta[topic]}',
        # Also output to a file for handy debugging
        'file:///vagrant/logs/eventbus.log',
    ]
    eventlogging::service { 'eventbus':
        port         => 8085,
        schemas_path => "${::eventschemas::path}/jsonschema",
        topic_config => "${::eventschemas::path}/config/eventbus-topics.yaml",
        outputs      => $outputs,
    }
}

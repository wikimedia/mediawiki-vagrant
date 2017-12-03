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

    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => {
            wgEventServiceUrl => 'http://localhost:8085/v1/events',
        },
    }

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

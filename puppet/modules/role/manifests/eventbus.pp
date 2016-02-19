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

    mediawiki::extension { 'EventBus':
        priority => $::LOAD_EARLY,
        settings => {
            wgEventServiceUrl => 'http://localhost:8085/v1/events',
        },
    }

    $topic_config = "${::eventlogging::path}/config/eventbus-topics.yaml"
    file { $topic_config:
        source => 'puppet:///modules/role/eventbus/topics.yaml',
    }

    $outputs = [
        # Output to Kafka
        'kafka:///localhost:9092?async=False',
        # Also output to a file for handy debugging
        'file:///vagrant/logs/eventbus.log',
    ]
    eventlogging::service { 'eventbus':
        port         => 8085,
        schemas_path => "${::eventschemas::path}/jsonschema",
        topic_config => $topic_config,
        outputs      => $outputs,
    }
}

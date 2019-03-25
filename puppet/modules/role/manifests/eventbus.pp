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

    $eventbus_url = 'http://localhost:8085/v1/events'
    $eventgate_url = 'http://localhost:8192/v1/events'

    # EventGate will eventually replace eventlogging-serivce-eventbus.
    # We'd run them both at the same time, but EventGate requires NodeJS >= 10,
    # which conflicts with other mediawiki services at this time.
    # Only install EventGate service if this hiera param is set.
    # NOTE: You'll also need to set npm::node_version: 10 in hiera
    # to use the eventgate class.
    $enable_eventgate = hiera('role::eventbus::enable_eventgate', false)
    if $enable_eventgate {
        require ::eventgate
    }

    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => template('role/eventbus/EventBus.php.erb'),
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

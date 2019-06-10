# == Class role::eventbus
#
# Sets up eventlogging-service-eventbus using eventbus-topics.yaml
# topic -> schema mapping, and mediawiki/event-schemas repository.
# This accepts HTTP POSTs on port 8085 and produceds valid events to
# Kafka and to logs/eventbus.log.
#
class role::eventbus {
    require ::kafka
    require ::eventschemas
    include ::changeprop

    # EventGate will replace eventlogging-serivce-eventbus.
    # EventGate requires NodeJS >= 10 which conflicts with other
    # mediawiki services at this time.
    # Install eventgate service if this hiera param is set, otherwise
    # install eventlogging-service-eventbus.
    # NOTE: You'll also need to set npm::node_version: 10 in hiera
    # to use the eventgate class.
    # As soon as we can require NodeJS 10 outright, we will remove support
    # for eventlogging-service-eventbus.
    $enable_eventgate = hiera('role::eventbus::enable_eventgate', false)
    if $enable_eventgate {
        require ::eventgate
        $eventgate_url = "http://localhost:${::eventgate::port}/v1/events"
    }
    else {
        require ::eventlogging
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

        $eventbus_url = 'http://localhost:8085/v1/events'
    }

    # Configure EventBus extension to produce events
    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => template('role/eventbus/EventBus.php.erb'),
    }

}

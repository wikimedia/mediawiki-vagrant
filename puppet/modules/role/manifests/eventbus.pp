# == Class role::eventbus
#
# Sets up mediawiki EventBus extension and an EventGate instance.
# EventGate listens for POSTs of events on port 8192
# and produces valid events to Kafka.
#
class role::eventbus {
    require ::kafka
    require ::eventschemas
    include ::changeprop

    # NOTE: Set npm::node_version: 10 in hiera
    $node_version = hiera('npm::node_version', undef)
    if (!$node_version or $node_version < 10) {
        fail('EventBus role requires the EventGate service, which requires NodeJS 10. Please set npm::node_version: 10 in hiera to install it.')
    }

    require ::eventgate
    $eventgate_url = "http://localhost:${::eventgate::port}/v1/events"

    # Configure EventBus extension to produce events to EventGate
    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => template('role/eventbus/EventBus.php.erb'),
    }

}

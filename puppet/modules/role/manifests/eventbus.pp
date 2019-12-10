# == Class role::eventbus
#
# Sets up mediawiki EventBus extension and an EventGate instance.
# EventGate listens for POSTs of events on port 8192
# and produces valid events to Kafka.
#
class role::eventbus {
    # NOTE: Set npm::node_version: 10 in hiera
    $node_version = hiera('npm::node_version', undef)
    if (!$node_version or $node_version < 10) {
        warning('EventBus role requires the EventGate service, which requires NodeJS 10. To use it, set npm::node_version: 10 in hiera. (Might break other services.)')
    }

    require ::eventgate
    $eventgate_url = $::eventgate::url # Used in EventBus.php.erb template.

    # TODO:
    # Refactor EventBus Configuration
    # https://phabricator.wikimedia.org/T229863

    # Configure EventBus extension to produce events to EventGate
    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => template('role/eventbus/EventBus.php.erb'),
    }

}

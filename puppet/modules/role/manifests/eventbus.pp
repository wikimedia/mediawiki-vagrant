# == Class role::eventbus
#
# Sets up mediawiki EventBus extension and an EventGate instance.
# EventGate listens for POSTs of events on port 8192.
#
# By default, eventgate will output events to the /vagrant/logs/eventgate-events.json
# log file, or to whatever the eventgate::output parameter is set (in hiera).
# If eventgate::output == 'kafka', Kafka will be installed and events will
# be produced to Kafka.
#
class role::eventbus {
    $node_version = lookup('npm::node_version')
    if $node_version < 16 {
        warning('EventBus role requires the EventGate service, which requires NodeJS 16. To use it, run `vagrant hiera npm::node_version 16 && vagrant provision`.')
    }

    include ::eventgate
    $eventgate_url = $::eventgate::url # Used in EventBus.php.erb template.

    # Configure EventBus extension to produce events to EventGate
    mediawiki::extension { 'EventBus':
        priority => $::load_early,
        settings => template('role/eventbus/EventBus.php.erb'),
    }

}

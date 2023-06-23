# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against schemas in srv/schemas/event, but logged locally.
#
# EventGate will be installed and run, and events will be produced via eventgate.
#
# By default, eventgate will output events to the /vagrant/logs/eventgate-events.json
# log file, or to whatever the eventgate::output parameter is set (in hiera).
# If eventgate::output == 'kafka', Kafka will be installed and events will
# be produced to Kafka.
#
class role::eventlogging {
    include ::role::syntaxhighlight

    # EventLogging will produce to EventGate at wgEventLoggingServiceUri.
    include ::eventgate
    $eventgate_url = $::eventgate::url # Used in EventLogging.php.erb template.s

    mediawiki::extension { 'EventLogging':
        priority => $::load_early,
        settings => template('role/eventlogging/EventLogging.php.erb'),
    }

    mediawiki::extension { 'EventStreamConfig':
        priority => $::load_early,
    }
}

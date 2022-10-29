# == Class eventgate
#
# Installs an EventGate service listening on internally port 8192.
# If $output == 'kafka', Kafka will be installed and EventGate will be configured
# to produce to Kafka.  Otherwise, the default is to log events to $output as a file path.
#
# EventGate is made available to POST events publicly at
#
#   http://eventgate.local.wmftest.net:8080/v1/events
#
# You can reference this URL in other puppet configs
# via the $::eventgate::url variable.
#
# This class does not set up any stream configs to enforce schemas
# in topics.
#
# NOTE: to use this class, you must set the npm::node_version hiera key to 10.
# Doing so will install NodeJS 10 instead of 6 and may break other NodeJS
# services if they are not compatible NodeJS 10.
#
class eventgate(
    $port      = 8192,
    $log_level = undef,
    $output    = '/vagrant/logs/eventgate-events.json'
) {
    $node_version = lookup('npm::node_version', {'default_value' => '6'})
    if $node_version != 10 {
        warning("eventgate requires NodeJS version 10 but was ${node_version}. To use it, run `vagrant hiera npm::node_version 10 && vagrant provision`. (Might break other services.)")
    }

    require ::eventschemas
    include ::mwv # to get $::mwv::tld


    $base_config = {
        'user_agent' => 'eventgate-vagrant',

        # This field in each event will be used to extract a
        # (possibly relative) schema uri.  The default is $schema.
        # An array of field names will cause EventGate to search for
        # fields by these names in each event, using the first match.
        'schema_uri_field' => '$schema',

        # If set, this URI will be prepended to any relative schema URI
        # extracted from each event's schema_field./
        'schema_base_uris' =>  [
            "${::eventschemas::path}/primary/jsonschema/",
            "${::eventschemas::path}/secondary/jsonschema/",
        ],

        # This field in each event will be used to extract a destination 'stream' name.
        # This will equal the destination Kafka topic, unless a topic prefix
        # is also configured.
        'stream_field' => 'meta.stream',
        'topic_prefix' => 'datacenter1.',

        # This field will be used in log messages to uniquely ID each event.
        'id_field' => 'meta.id',

        # If a validation error is encountered, a validation error event
        # will be produced to this stream.
        'error_stream' =>  'eventgate-vagrant.error.validation',

        # If test_events is set, a GET /v1/_test/events route will be added.
        # When this route is requested, these test_events will be processed through EventGate
        # as if it they were directly POSTed to /v1/events.
        # This is useful for readiness probes that want to make sure the service
        # is alive and ready to produce events end to end.
        'test_events' => {
            '$schema' => '/test/event/1.0.0',
            'meta' => {
              'stream' => 'eventgate-vagrant.test.event',
            },
            'test' => 'eventgate-vagrant test event',
        },

        # If this is set and an event does not have schema_uri_field, the value of
        # event[schema_uri_field] will be set to the value of this HTTP query paramater
        'schema_uri_query_param' => 'schema_uri',

        # If this is set and an event does not have stream_field, the value of
        # event[stream_field] will be set to the value of this HTTP query paramater.
        'stream_query_param' => 'stream',
    }

    if $output == 'kafka' {
        require ::kafka
        $extra_config = {
            # eventgate-wikimedia.js factory uses Kafka
            'eventgate_factory_module' => 'eventgate-wikimedia.js',
            'kafka' => {
                'conf' => {
                    'metadata.broker.list' => 'localhost:9092',
                },
            },
        }
    } else {
        # eventgate-wikimedia-dev.js outputs to stdout, or a log file.
        $eventgate_factory_module = 'eventgate-wikimedia-dev.js'
        $extra_config = {
            'eventgate_factory_module' => 'eventgate-wikimedia-dev.js',
            'output_path' => $output,
        }
    }

    $config = merge($base_config, $extra_config)


    # eventgate-wikimedia has the WMF specific implementation of EventGate.
    # It specifies the eventgate (service-runner) package as a dependency
    # and runs the eventgate from it.
    service::node { 'eventgate-wikimedia':
        git_remote => 'https://gerrit.wikimedia.org/r/eventgate-wikimedia',
        port       => $port,
        log_level  => $log_level,
        module     => 'eventgate',
        entrypoint => 'app',
        script     => 'node_modules/eventgate/server.js',
        config     => $config,
    }

    # Add a reverse proxy from eventgate.local.wmftest.net to the
    # eventgate-wikimedia service.
    apache::reverse_proxy { 'eventgate':
        port => $port,
    }
    # The reverse_proxy will make this URL publicly addressable.
    # This is used by event clients (EventBus, EventLogging, etc.) to POST event data.
    $url = "http://eventgate${::mwv::tld}${::port_fragment}/v1/events"

    # make a symlink from srv/eventgate -> eventgate-wikimedia/node_modules/eventgate for
    # easier access to the EventGate package code for development purposes.
    file { '/vagrant/srv/eventgate':
        ensure  => 'link',
        target  => 'eventgate-wikimedia/node_modules/eventgate',
        require => Service::Node['eventgate-wikimedia'],
    }
}

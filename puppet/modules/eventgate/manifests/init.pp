# == Class eventgate
#
# Installs an EventGate service listening on port 8192 and
# producing to Kafka.
#
# This class does not set up any stream configs to enforce schemas
# in topics.
#
# NOTE: to use this class, you must set npm::node_version: 10 in
# hieradata/common.yaml. Doing so will install NodeJS 10 instead
# of 6 and may break other NodeJS services if they are not compatible
# NodeJS 10.
#
class eventgate(
    $port      = 8192,
    $log_level = undef,
) {
    $node_version = hiera('npm::node_version', '6')
    if $node_version != 10 {
        warning("eventgate requires NodeJS version 10 but was ${node_version}. To use it, set npm::node_version: 10 in hieradata/common.yaml. (Might break other services.)")
    }

    require ::kafka
    require ::eventschemas

    $url = "http://dev.wiki.local.wmftest.net:${port}/v1/events"

    require_package('librdkafka1', 'librdkafka++1', 'librdkafka-dev')

    # A simple config suitable for producing valid events to to Kafka.
    $config = {
        'user_agent' => 'eventgate',
        'eventgate_factory_module' => 'eventgate-wikimedia.js',

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
        'error_stream' =>  'eventgate.error.validation',

        # kafka configs go here.
        'kafka' => {
              'conf' => {
                    'metadata.broker.list' => 'localhost:9092',
            },
        },
    }

    # eventgate-wikimedia has the WMF specific implementation of EventGate.
    # It specifies the eventgate (service-runner) package as a dependency
    # and runs the eventgate from it.
    service::node { 'eventgate-wikimedia':
        git_remote      => 'https://gerrit.wikimedia.org/r/eventgate-wikimedia',
        port            => $port,
        log_level       => $log_level,
        module          => 'eventgate',
        entrypoint      => 'app',
        script          => 'node_modules/eventgate/server.js',
        config          => $config,
        # Use debian librdkafka package
        npm_environment => ['BUILD_LIBRDKAFKA=0']
    }

    # make a symlink from srv/eventgate -> eventgate-wikimedia/node_modules/eventgate for
    # easier access to the EventGate package code for development purposes.
    file { '/vagrant/srv/eventgate':
        ensure  => 'link',
        target  => 'eventgate-wikimedia/node_modules/eventgate',
        require => Service::Node['eventgate-wikimedia'],
    }
}

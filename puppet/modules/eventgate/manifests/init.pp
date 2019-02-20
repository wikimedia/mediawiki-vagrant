# == Class eventgate
#
# Installs an EventGate service listening on port 8192 and
# producing to Kafka. This EventGate service will accept
# older 'eventbus' style events as well as new JSONSchema draft 7
# ones being developed for the Modern Event Platform program.
# EventGate is meant to replace the EventBus service.
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
        fail("eventgate requires NodeJS version 10 but was ${node_version}. Set npm::node_version: 10 in hieradata/common.yaml")
    }

    require ::kafka
    require ::eventschemas

    # A simple config suitable for producing valid events to to Kafka.
    $config = {
        'user_agent' => 'eventgate',
        'eventgate_factory_module' => '../lib/factories/wikimedia-eventgate',

        # This field in each event will be used to extract a
        # (possibly relative) schema uri.  The default is $schema.
        # An array of field names will cause EventGate to search for
        # fields by these names in each event, using the first match.
        'schema_uri_field' => ['$schema', 'meta.schema_uri'],

        # If set, this URI will be prepended to any relative schema URI
        # extracted from each event's schema_field./
        # This should be the path to the local checkout of
        # https://github.com/wikimedia/mediawiki-event-schemas
        'schema_base_uris' =>  ["${::eventschemas::path}/jsonschema/"],

        # This field in each event will be used to extract a destination 'stream' name.
        # This will equal the destination Kafka topic, unless a topic prefix
        # is also configured.
        'stream_field' => ['meta.stream', 'meta.topic'],
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

    service::node { 'eventgate':
        port       => $port,
        log_level  => $log_level,
        git_remote => 'https://github.com/wikimedia/eventgate.git',
        config     => $config,
    }
}

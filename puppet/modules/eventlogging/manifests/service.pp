# == Define eventlogging::service::service
# HTTP Produce Service for EventLogging
#
# == Parameters
#
# [*outputs*]
#   Array of EventLogging output URIs.
#
# [*schemas_path*]
#   Path to schemas repository.  JSONSchema files will be preloaded
#   and cached out of this directory.
#   Default: $eventlogging::package::path/config/schemas/jsonschema
#
# [*topic_config*]
#   Path to topic config file.  This file specifies what schema names
#   are allowed to be produced to which topics.
#
# [*port*]
#   Port on which this service will listen.  Default: 8085.
#
# [*num_processes*]
#   Number of processors for Tornado to start.  Each will listen
#   on $port.  Default: undef (1).  Instead of increasing this,
#   you may want to consider deploying several of these services
#   each listening on a different port and load balanced.  This
#   may be easier to monitor.
#
define eventlogging::service(
    $outputs,
    $schemas_path,
    $topic_config,
    $port                = 8085,
    $num_processes       = undef, # default 1
)
{
    require ::eventlogging

    # Local variable for ease of use and reference in templates.
    $eventlogging_path = $::eventlogging::path

    $basename = regsubst($title, '\W', '-', 'G')
    $service_name = "eventlogging-service-${basename}"
    $config_file = "${eventlogging_path}/config/${service_name}"

    # Python argparse config file for eventlogging-service
    file { $config_file:
        content => template('eventlogging/service.erb'),
    }

    systemd::service { $service_name:
        ensure             => 'present',
        template_name      => 'eventlogging-service',
        service_params     => {
            subscribe => File[$config_file],
        },
        epp_template       => true,
        template_variables => {
            'eventlogging_path' => $eventlogging_path,
            'config_file'       => $config_file,
        },
    }
}

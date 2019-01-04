# == Define: service::uwsgi
#
# service::uwsgi provides a common wrapper for setting up uwsgi.js services
# based on service-runner and/or service-template-uwsgi. Note that most of
# the facts listed as parameters to this class are set correctly via the
# service class and/or Hiera. The only required parameter is the port.
# Alternatively, config may be given as well if needed.
#
# === Parameters
#
# [*port*]
#   Port on which to run the service
#
# [*config*]
#   The individual service's config to use. It can be eaither a hash of
#   key => value pairs, or a YAML-formatted string. Note that the complete
#   configuration will be assembled using the bits given here and common
#   uwsgi service configuration directives. Default: {}
#
# [*git_remote*]
#   The git clone URL. Needs to be set only if the service is to be cloned
#   from a source different than Gerrit. Default: undef
#
define service::uwsgi(
    $port,
    $config     = {},
    $git_remote = undef,
) {
    require ::service

    unless $title and size($title) > 0 {
        fail('No name for this resource given!')
    }
    unless $port and $port =~ Integer {
        fail('Service port must be specified and must be a number!')
    }

    $remote = $git_remote ? {
        undef   => sprintf($::git::urlformat, "mediawiki/services/${title}"),
        default => $git_remote
    }

    $dir = "${::service::root_dir}/${title}"
    $log_dir = "${::service::log_dir}/${title}"
    $log_file = "${log_dir}/${title}.log"

    git::clone { $title:
        directory => $dir,
        remote    => $remote,
    }
    service::gitupdate { $title:
        dir          => $dir,
        restart      => true,
        service_name => "uwsgi-${title}",
    }

    file { $log_dir:
        ensure => 'directory',
        mode   => '0666',
        owner  => $::share_owner,
        group  => $::share_group,
    }
    file { $log_file:
        ensure => present,
        mode   => '0666',
        owner  => $::share_owner,
        group  => $::share_group,
    }
    file { "/etc/logrotate.d/${title}":
        content => template('service/logrotate.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    $base_config = {
        plugins     => 'python, python3, logfile, logsocket',
        master      => true,
        http-socket => "0.0.0.0:${port}",
        processes   => 1,
        die-on-term => true,
        log-route   => ['local .*'],
        log-encoder => [
            # lint:ignore:single_quote_string_with_variables
            # Add a timestamps to local log messages
            'format:local [${strftime:%%Y-%%m-%%dT%%H:%%M:%%S}] ${msgnl}',
            #lint:endignore
        ],
        logger      => [
            "local file:${log_file}",
        ],
    }
    $complete_config = deep_merge($base_config, $config)

    uwsgi::app { $title:
        settings => {
            uwsgi => $complete_config,
        }
    }
}

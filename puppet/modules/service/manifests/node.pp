# == Define: service::node
#
# service::node provides a common wrapper for setting up Node.js services
# based on service-runner and/or service-template-node. Note that most of
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
#   node service configuration directives. Default: {}
#
# [*module*]
#   The service's start-up module. Services based on service-template-node
#   do not need to change this. Default: ./app.js
#
# [*entrypoint*]
#   If the service's starter module exports a specific function that should be
#   used on start-up, set this parameter to the function's name. Default: ''
#
# [*script*]
#   The script used for starting the service. Default: server.js
#
# [*git_remote*]
#   The git clone URL. Needs to be set only if the service is to be cloned
#   from a source different than Gerrit. Default: undef
#
# [*log_level*]
#   The service's log level. Default: $::service::log_level
#
# === Examples
#
# To set up a service named myservice on port 8520 and with a templated
# configuration, use:
#
#    service::node { 'myservice':
#        port   => 8520,
#        config => template('myservice/config.yaml.erb'),
#    }
#
# Likewise, you can supply the configuration directly as a hash:
#
#    service::node { 'myservice':
#        port   => 8520,
#        config => {
#            param1 => 'val1',
#            param2 => $myvar
#        },
#    }
#
define service::node(
    $port,
    $config     = {},
    $module     = './app.js',
    $entrypoint = '',
    $script     = 'server.js',
    $git_remote = undef,
    $log_level  = undef,
) {

    require ::service

    require ::npm
    require ::npm::globals

    # we do not allow empty names
    unless $title and size($title) > 0 {
        fail('No name for this resource given!')
    }

    # sanity check since a default port cannot be assigned
    unless $port and $port =~ Integer {
        fail('Service port must be specified and must be a number!')
    }

    # set up the remote URL
    $remote = $git_remote ? {
        undef   => sprintf($::git::urlformat, "mediawiki/services/${title}"),
        default => $git_remote
    }

    # the service's location
    $dir = "${::service::root_dir}/${title}"
    # the local log file name
    $log_file = "${::service::log_dir}/${title}.log"
    # set the log level
    $loglev = $log_level ? {
        undef   => $::service::log_level,
        default => $log_level
    }
    # ensure the RB port is defined for the config
    $restbase_port = defined(Class['restbase']) ? {
        true    => $::restbase::port,
        default => 7231,
    }

    # the repo
    git::clone { $title:
        directory => $dir,
        remote    => $remote,
    }

    # install the dependencies
    npm::install { $dir:
        directory => $dir,
        require   => Git::Clone[$title],
    }

    # the service's configuration file
    file { "${title}_config_yaml":
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0664',
        path    => "${dir}/config.vagrant.yaml",
        content => merge_config(
            template('service/node/config.yaml.erb'),
            $config
        ),
        require => Git::Clone[$title],
    }

    # set the log file's permissions
    file { $log_file:
        ensure => present,
        mode   => '0666',
        owner  => $::share_owner,
        group  => $::share_group,
    }

    # log rotation
    file { "/etc/logrotate.d/${title}":
        content => template('service/logrotate.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    # schedule the service for git-updates via vagrant git-update
    service::gitupdate { $title:
        type    => 'nodejs',
        update  => true,
        restart => true,
    }

    # the service definition
    systemd::service { $title:
        template_name      => 'node',
        service_params     => {
            subscribe => [
                File["${title}_config_yaml"],
                Npm::Install[$dir],
            ],
        },
        epp_template       => true,
        template_variables => {
            title   => $title,
            uptitle => inline_template('<%= @title.gsub(/[^a-zA-Z0-9_]/, "_").upcase %>'),
            dir     => $dir,
            port    => $port,
            script  => $script,
        },
        require            => Git::Clone[$title],
    }
}

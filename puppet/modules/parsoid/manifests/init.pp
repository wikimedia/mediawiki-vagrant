# == Class: parsoid
#
# Parsoid is a wiki runtime which can translate back and forth between
# MediaWiki's wikitext syntax and an equivalent HTML / RDFa document model with
# better support for automated processing and visual editing. Its main user
# currently is the visual editor project.
#
# === Parameters
#
# [*port*]
#   the port Parsoid will be running on
#
# [*domain*]
#   The MediaWiki host domain name.
#
# [*uri*]
#   The full URI to the MediaWiki api.php to use.
#
# [*use_php_preprocessor*]
#   If true, use the PHP pre-processor to expand templates via the
#   MediaWiki API.
#
# [*use_selser*]
#   Use selective serialization.
#
# [*allow_cors*]
#   Domains that should be permitted to make cross-domain requests.
#   If false or undefined, disables CORS.
#
# [*log_level*]
#   the lowest level to log (trace, debug, info, warn, error, fatal)
#
class parsoid (
    $port,
    $domain,
    $uri,
    $use_php_preprocessor,
    $use_selser,
    $allow_cors,
    $log_level = undef,
) {

    require ::service

    # the location of the settings file
    $settings_file = '/etc/parsoid.localsettings.vagrant.js'
    # the local log file name
    $log_file = "${::service::log_dir}/parsoid-processor.log"
    # set the log level
    $loglev = $log_level ? {
        undef   => $::service::log_level,
        default => $log_level
    }

    # previously, Parsoid's deploy repo was being installed
    # in /vagrant/srv/parsoid, so make sure we have the correct
    # repo (the source one) checked out
    exec { 'parsoid-check-deploy-repo':
        command => "/bin/rm -rf ${::service::root_dir}/parsoid",
        onlyif  => "/usr/bin/test -d ${::service::root_dir}/parsoid/src",
        before  => Service::Node['parsoid'],
    }

    file { $settings_file:
        ensure  => present,
        owner   => 'root',
        mode    => '0644',
        content => template('parsoid/localsettings.js.erb'),
    }

    service::node { 'parsoid':
        port       => $port,
        module     => 'lib/index.js',
        entrypoint => 'apiServiceWorker',
        script     => 'bin/server.js',
        config     => {
            localsettings => $settings_file,
        },
        log_level  => $log_level,
        require    => File[$settings_file],
    }

}

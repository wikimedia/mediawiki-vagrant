# == Class: electron
# Sets up the electron[https://github.com/wikimedia/mediawiki-services-electron-render/blob/master/README.md] service
# which renders PDF files from web pages.
#
# FIXME some of the config is in puppet/modules/restbase/templates/config.yaml.erb
#
# === Parameters
#
# [*port*]
#   Port to listen on
#
# [*vhost_name*]
#   Hostname of the electron service (example: 'electron.local.wmftest.net').
#
# [*secret*]
#   Secret needed to access the service
#
# [*home_dir*]
#   Homedir for the headless browser used by electron.
#   Must be ownable by the web user (ie. non-shared).
#
# [*log_file*]
#   Log file for electron and xvfb.
#
class electron(
    $port,
    $vhost_name,
    $secret,
    $home_dir,
    $log_file,
) {
    require_package([
        'xvfb',
        'libgtk2.0-0',
        'ttf-mscorefonts-installer',
        'libnotify4',
        'libgconf2-4',
        'libxss1',
        'libnss3',
        'dbus-x11',
    ])

    $dir = "${::service::root_dir}/electron-render-service"

    git::clone { 'electron-render-service':
        directory => $dir,
        remote    => 'https://github.com/wikimedia/mediawiki-services-electron-render.git',
    }

    npm::install { $dir:
        directory => $dir,
        require   => Git::Clone['electron-render-service'],
    }

    service::gitupdate { 'electron-render-service':
        type    => 'nodejs',
        update  => true,
        restart => true,
    }

    file { $home_dir:
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        require => Git::Clone['electron-render-service'],
    }

    systemd::service { 'electron-render-service':
        service_params => {
            subscribe => Npm::Install[$dir],
        },
        require        => [
            Git::Clone['electron-render-service'],
            File[$home_dir],
        ],
    }

    apache::reverse_proxy { 'electron':
        port => $port,
    }
}

# == Class: role::addimage
# Sets up the Add Image pipeline.
# See https://wikitech.wikimedia.org/wiki/Add_Image
#
# === Parameters
#
# [*db_name*]
#   Logical MySQL database name (example: 'addimage').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'addlink_user').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*service_dir*]
#   Path where mwaddlink should be installed (example: '/srv/mwaddlink').
#
# [*service_port*]
#   Port which the service listens on (example: 8000).
#
class role::addimage (
    $service_dir,
    $service_port,
) {
    require ::docker
    include ::role::growthexperiments

    $server_url = $::mediawiki::server_url

    git::clone { 'mediawiki/services/image-suggestion-api':
        directory => $service_dir,
    }
    service::gitupdate { 'image-suggestion-api':
        dir     => $service_dir,
        restart => true,
    }

    file { "${service_dir}/.pipeline/blubber.dev.yaml":
        source  => 'puppet:///modules/role/addimage/blubber.dev.yaml',
        require => Git::Clone['mediawiki/services/image-suggestion-api'],
    }

    # small test database with only four pages:
    # Ərəb,_Lachin
    # Šušu_Gioro
    # Štefan_Sečka
    # Štefan_Bednár
    file { "${service_dir}/static/database.db":
        source  => 'puppet:///modules/role/addimage/image-suggestion-api.db',
        require => Git::Clone['mediawiki/services/image-suggestion-api'],
    }

    systemd::service { 'image-suggestion-api':
        ensure             => 'present',
        service_params     => {
            require => [
                File["${service_dir}/.pipeline/blubber.dev.yaml"],
                File["${service_dir}/static/database.db"],
            ],
        },
        epp_template       => true,
        template_variables => {
            service_dir  => $service_dir,
            service_port => $service_port,
            server_url   => $server_url,
        },
        template_dir       => 'role/addimage/systemd',
    }

    $service_url = "http://image-suggestion-api${::mwv::tld}${::port_fragment}"
    apache::reverse_proxy { 'image-suggestion-api':
        port => $service_port,
    }
    mediawiki::settings { 'GrowthExperiments-Mwaddimage':
        values => template('role/addimage/settings.php.erb'),
    }
    mediawiki::import::text { 'VagrantRoleAddImage':
        content => template('role/addimage/VagrantRoleAddImage.wiki.erb'),
    }
}

